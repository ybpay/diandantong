module Ddt
  module OrderService
    module Cart
      class Base
        include OrderService::Concern::Base
        include OrderService::Cart::Concern::Contents
        include OrderService::Cart::Concern::Updater
        include OrderService::Cart::Concern::Adjust
        include OrderService::Cart::Concern::Pay
        include OrderService::Cart::Concern::CartModel
        include OrderService::Cart::Concern::SessionStore
        include OrderService::Order::Concern::OrderType
        belongs_to :user, class_name: "Ddt::BaseUser", foreign_key: :base_user_id
        belongs_to :vip_info, class_name: "Ddt::VipInfo"
        belongs_to :branch
        belongs_to :shop
        belongs_to :waiter, class_name: "Ddt::Account"
        belongs_to :operator, polymorphic: true
        belongs_to :coupon
        attr_accessor :note, :pay_method, :vip_discount
        attr_accessor :is_local_printed
        attr_accessor :track_from
        attr_accessor :number
        attr_accessor :terminal_id
        attr_accessor :credits_deduction_amount, :card_deduction_amount
        attr_accessor :credits_deduction, :card_deduction

        acts_as_type :track_from, [:FromWechat, :FromWebpos, :FromWebstore, :FromApp, :FromWifi, :FromUnknow],
                                  %W[微信 收银端 网站 App Wifi堂点 未知]

        acts_as_type :pay_method, [:pay_on_face, :pay_on_arrive, :pay_on_receive, :alipay, :wechatpay, :baidupay, :vip_card_pay, :bank_card_pay, :wechatpay_offline, :alipay_offline],
                                  %W[现金结账 到店付款 货到付款 支付宝 微信支付 百度钱包 会员卡支付 银行卡支付 线下微信支付 线下支付宝支付]
        def initialize(params={})
          self.branch = params.fetch(:branch)
          self.shop = self.branch.shop
          if params[:user].present?
            self.user = params[:user]
            self.vip_info = self.user.vip_info
          end
          if params[:vip_info].present?
            self.vip_info = params[:vip_info]
            self.user = self.vip_info.user
          end
          self.vip_discount = user.present? ? user.vip_info.discount : 1
          self.waiter = params.fetch(:waiter, nil)
          self.coupon = params.fetch(:coupon, nil)
          self.operator = params.fetch(:operator, self.user || self.waiter)
          @note = params.fetch(:note, "")
          @pay_method = params.fetch(:pay_method, default_pay_method)
          @is_local_printed = params.fetch(:is_local_printed, false)
          @terminal_id = params.fetch(:terminal_id, nil)
          @track_from = params.fetch(:track_from, :FromUnknow)
          collection_attr_names.each{|attr_name| self.send("#{attr_name}=", [])}
          update_line_items(params.fetch(:line_itemables, []))
          update_form_contents(params.fetch(:form_contentables, []))
          init_info(params)
          update_discount
        end

        def init_info(params={})
        end

        concerning :Place do
          def place
            if self.valid?
              transaction do
                create_deduction
                update_discount
                self.number = generater_order_number
                create_pay_item
                add_change_log(:order_place, description: note)
                result = OrderService::Api::Order.place(self.to_options)
                order = OrderService::Order::Base.init(result.merge(terminal_id: terminal_id))
                order.operator = self.operator
                after_place(order, order.operator)
                order
              end
            end
          end

          private
          def generater_order_number
            order_number_resource = branch.competition_resources.where(name: :order_number).lock(true).first
            # TODO: 如果改时区了，会出现 updated_at.to_date 同步变化，出现跨天 BUG。 如果SHOP时区固定下来，可以不处理
            if order_number_resource.value.present? && order_number_resource.updated_at.to_date == order_number_resource.shop_today
              new_number = order_number_resource.value.next
            else
              new_number = "B#{branch_id}#{order_number_resource.shop_time_now.strftime('%Y%m%d')}#{'%.04d' % 1}"
              new_number = loop do
                # break new_number
                if OrderService::Order::Base.where(number: new_number).count >= 1
                  new_number = new_number.next
                else
                  break new_number
                end
              end
            end
            order_number_resource.value = new_number
            order_number_resource.save
            new_number
          end

          def after_place(order, operator)
            perform_deduction_after_place(order)
            add_promotion_relation_after_place(order.id)
            set_coupon_to_applied(order,operator)
            order.after_place
          end

          def add_change_log(type, options={})
            change_log = OrderService::OrderChangeLog.new(
              type: "Ddt::OrderChangeLog::#{type.to_s.classify}",
              operator: operator,
              cart: self,
              description: options[:description]
            )
            self.order_change_logs.push(change_log)
          end

          def set_coupon_to_applied(order, operator)
            if coupon.present? && adjustments.coupon.count > 0
              coupon.set_applied(order, operator)
            end
          end
        end

        collection_attr_accessor :line_items, :pay_items, :adjustments, :order_change_logs, :form_contents
        delegate :item_total, :item_count, :item_total_for_discount, :combos, :variants, to: :line_items
        delegate :pay_item_total, :pay_item_state, :pay_method_names, to: :pay_items
        delegate :adjustment_total, to: :adjustments

        def evaluate_promotion?
          !self.is_FromWebpos? || branch.promotion_in_webpos?
        end

        alias_method :computable_price, :item_total

        def in_pay_methods?(pay_methods)
          self.pay_method.present? && pay_methods.any?{|method| method.name_sym == self.pay_method.to_s }
        end

        def tax_total
          self.shop.calculate_tax(item_total)
        end

        def total
          [item_total + tax_total + adjustment_total + extra_amount, 0].max
        end
        alias_method :amount_for_pay, :total

        def type
          "Ddt::#{self.class.name.demodulize}Order"
        end

        def to_options
          options = {
            state: :pending,
            placed_at:  current_time,
            created_at: current_time,
            updated_at: current_time,
          }
          collection_attr_names.each do |attr_name|
            options[attr_name] = self.send(attr_name).changed_values
          end
          [ :type, :shop_id, :branch_id, :base_user_id, :vip_info_id, :waiter_id, :number, :vip_discount,
            :pay_method, :is_local_printed, :track_from,
            :item_count, :item_total, :adjustment_total, :tax_total, :total, :amount_for_pay, :pay_item_total, :pay_method_names, :pay_item_state,
           ].each{ |key| options[key] = self.send(key) }
           options
        end

        def is_vip?
          vip_info.present? && !vip_info.is_default
        end

        private
        def default_pay_method
        end

        def extra_amount
          0.0
        end

        concerning :Deduction do
          def add_card_deduction(amount)
            self.card_deduction_amount = amount if amount && amount > 0
          end

          def add_credits_deduction(amount)
            self.credits_deduction_amount = amount if amount && amount > 0
          end

          private
          def create_deduction
            if card_deduction_amount
              self.card_deduction = CardDeduction.create(shop: shop, amount: card_deduction_amount, wallet: self.user.card_wallet)
              adjust(reason: :card_deduction, source: self.card_deduction)
            end
            if credits_deduction_amount
              self.credits_deduction = CreditsDeduction.create(shop: shop, amount: credits_deduction_amount, wallet: self.user.credits_wallet)
              adjust(reason: :credits_deduction, source: self.credits_deduction, need_apportion: true)
            end
          end

          def perform_deduction_after_place(order)
            if self.card_deduction
              self.card_deduction.update(order: order)
              self.user.card_wallet.deduct(self.card_deduction)
            end
            if self.credits_deduction
              self.credits_deduction.update(order: order)
              self.user.credits_wallet.deduct(self.credits_deduction)
            end
          end
        end

        concerning :Validation do
          included do
            validate :check_collection_attr_valid
            validate :check_user_blocked
            validate :check_stock_is_enough
            validate :check_vip_card_pay_amount_enough
            validate :check_deduction_amount_enough
            validate :check_pay_method
          end

          def check_collection_attr_valid
            collection_attr_names.each do |attr_name|
              self.send(attr_name).each do |item|
                self.errors[attr_name] += item.errors.full_messages unless item.valid?
              end
            end
          end

          def check_stock_is_enough
            result = line_items.count_stock
            if !result[:enough]
              self.errors[:base] << " #{result[:msgs].join(", ")}"
            end
          end

          def check_user_blocked
            self.errors[:base] << "对不起，餐厅已经禁止了您的自助点餐行为。如有疑问，请联系商家解决" if user.present? && user.is_blocked?
          end

          def check_vip_card_pay_amount_enough
            self.errors[:base] << "会员可用余额不足"  if is_vip_card_pay? && user.present? && user.available_card_wallet_amount.to_f < self.total.to_f
          end

          def check_item_count
            self.errors[:base] << "订单不能为空" if item_count == 0
          end

          def check_deduction_amount_enough
            self.errors[:base] << "积分不足" if credits_deduction_amount && user.present? && user.credits_wallet.amount < credits_deduction_amount
            self.errors[:base] << "余额不足" if card_deduction_amount && user.present? && user.card_wallet.amount.to_f < card_deduction_amount.to_f
          end

          def check_pay_method
            if self.pay_method.present?
              self.errors[:base] << "不支持该支付方式" if pay_method_blacklist.include?(self.pay_method.to_sym)
            end
          end
        end


      end
    end
  end
end
