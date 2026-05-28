module Ddt
  module OrderService
    module Order
      class Base
        include OrderService::Concern::Base
        include AASM
        include OrderService::Order::Concern::ClassModel
        include OrderService::Order::Concern::OrderType
        include OrderService::Order::Concern::Adjust
        include OrderService::Order::Concern::Contents
        include OrderService::Order::Concern::Deduction
        include OrderService::Order::Concern::Pay
        include OrderService::Order::Concern::Updater
        include OrderService::Order::Concern::SaveChange
        include OrderService::Order::Concern::StockSale
        include OrderService::Order::Concern::BindScene
        include OrderService::Order::Concern::Path
        include OrderService::Order::Concern::LatLng
        attr_accessor_with_dirty :id, :type, :number, :state, :item_count,
                      :item_total, :adjustment_total, :total, :pay_item_total, :tax_total, :amount_for_pay,
                      :pay_item_state, :pay_method, :multi_pay_item, :pay_method_names, :anti_settlement,
                      :track_from, :cancel_reason, :is_local_printed, :vip_discount, :deleted_at, :delete_by_admin, :disable_discount_amount, :moling_amount,:delivery_man_id
        # time
        attr_accessor_with_dirty :completed_at, :created_at, :updated_at, :placed_at, :deleted_at, :paid_at, :confirmed_at, :canceled_at
        # delivery
        attr_accessor_with_dirty :shipment_total, :shipment_state,
                      :delivery_name, :delivery_phone, :delivery_address, :delivery_zone_name,
                      :delivery_date, :delivery_time_display,
                      :latitude, :longitude, :location_label
        # eat_in_hall
        attr_accessor_with_dirty :table_id, :guest_num, :table_name, :table_zone_name
        # fastfood
        attr_accessor_with_dirty :food_number
        # reservation
        attr_accessor_with_dirty :related_order_id, :prepayment_type,
                      :reservation_table_zone_name, :reservation_table_name,
                      :reservation_date, :reservation_time_point_display,
                      :reservation_name, :reservation_phone, :reservation_gender
        attr_accessor :operator, :terminal_id
        attr_accessor :ignore_notification

        belongs_to :shop
        belongs_to :branch, with_discarded: true
        belongs_to :user, class_name: "Ddt::BaseUser", foreign_key: :base_user_id
        belongs_to :vip_info
        belongs_to :waiter, class_name: "Ddt::Account"
        belongs_to :settle_account, class_name: "Ddt::Account"
        has_one :order_ext
        delegate :name, to: :waiter, prefix: true, allow_nil: true
        delegate :name, to: :settle_account, prefix: true, allow_nil: true
        delegate :refunded_amount, to: :order_ext
        has_one :comment
        has_one :coupon, foreign_key: :applied_to_order_id
        has_one :voucher, foreign_key: :applied_to_order_id
        has_one :invoice
        has_and_belongs_to_many :promotions, join_table: 'ddt_promotions_orders'
        has_and_belongs_to_many :disabled_promotions, join_table: 'ddt_orders_disabled_promotions', association_foreign_key: :promotion_id, class_name: "Ddt::Promotion"
        has_one :verify_vip_info_qr_code_scene, as: :owner
        has_many :order_calls
        has_many :payments
        has_one :promotion_event

        acts_as_type :type, [
          "Ddt::DeliveryOrder",
          "Ddt::EatInHallOrder",
          "Ddt::FastfoodOrder",
          "Ddt::ReservationOrder",
          "Ddt::GrouponOrder",
          "Ddt::RechargeOrder",
          "Ddt::PaymentOrder"], %W(外送 堂点 快餐 预约 团购 充值 买单)
        acts_as_type :pay_method, [:pay_on_face, :pay_on_arrive, :pay_on_receive, :alipay, :wechatpay, :baidupay, :vip_card_pay, :bank_card_pay, :wechatpay_offline, :alipay_offline], %W(现金结账 到店付款 货到付款 支付宝 微信支付 百度钱包 会员卡支付 银行卡支付 线下微信支付 线下支付宝支付)
        acts_as_type :track_from, [:FromWechat, :FromWebpos, :FromWebstore, :FromApp, :FromWifi, :FromUnknow], %W[微信 收银端 网站 App Wifi堂点 未知]

        alias_method :place_type_name, :track_from_name
        acts_as_type :pay_item_state, [:unpaid, :paid, :partial_paid, :none], %w(未支付 已支付 部分支付 未支付)

        acts_as_type :state, [:pending, :confirmed, :completed, :canceled, :merged, :refunding, :refunded], %W[待处理 已确认 已完成 已取消 已并台 退款中 已退款]

        collection_attr_accessor :line_items, :pay_items, :adjustments, :order_change_logs, :line_item_trace_points, :form_contents
        delegate :item_total_for_discount, :combos, :variants, :products, to: :line_items

        get_with_shop_time_zone :completed_at, :created_at, :updated_at, :placed_at, :paid_at, :confirmed_at, :canceled_at
        boolean_method_for :multi_pay_item, :anti_settlement, :is_local_printed

        class << self
          delegate *OrderService::Orders.query_methods, to: OrderService::Orders
        end

        def self.init(params={})
          if params[:type] =~ /^Ddt::(.+)Order$/
            OrderService::Order.const_get($1).new(params)
          end
        end

        def initialize(params={})
          init(params)
        end

        def init(params)
          params.except(collection_attr_names).each do |key, value|
            self.send("#{key}=", value)
          end
          self.operator = params.fetch(:operator, Ddt::BaseUser.current || Ddt::Account.current)
          collection_attr_names.each do |attr_name|
            if params[attr_name].present?
              if attr_name == :adjustments
                self.adjustments =  params.fetch(attr_name).map{|attrs|
                  item_adjustments = attrs.delete(:item_adjustments).map{|hash| OrderService::Adjustment.new(hash.merge(order: self))}
                  adjustment = OrderService::Adjustment.new(attrs.merge(order: self))
                  adjustment.item_adjustments = item_adjustments
                  adjustment
                }
              else
                self.send("#{attr_name}=", params.fetch(attr_name).map{|attrs|
                  OrderService.const_get(attr_name.to_s.classify).new(attrs.merge(order: self))
                })
              end
            end
          end
          changes_applied
        end

        def reload(options={})
          result = OrderService::Api::Order.get(self.id, options)
          init(result)
          self
        end

        def reload_line_item_trace_points
          result = OrderService::Api::Order.get(self.id, select: [:id], includes: [:line_item_trace_points])
          self.line_item_trace_points = result[:line_item_trace_points].map{|attrs|
            OrderService::LineItemTracePoint.new(attrs.merge(order: self))
          }
          self
        end

        aasm column: :state, no_direct_assignment: true do
          state :pending, :confirmed, :completed, :canceled, :merged, :refunding, :refunded, initial: :pending

          event :confirm do
            transitions from: :pending, to: :confirmed
          end
          event :complete do
            transitions from: :confirmed, to: :completed
          end
          event :init_refund do
            transitions from: :completed, to: :refunding
          end
          event :complete_refund do
            transitions from: :refunding, to: :refunded
          end
          event :cancel_refund do
            transitions from: :refunding, to: :completed
          end
          event :cancel do
            transitions from: [:pending, :confirmed], to: :canceled
          end
          event :merged do
            transitions from: [:pending, :confirmed], to: :merged
          end
          after_transition on: :confirm, do: :after_confirm
          after_transition on: :complete, do: :after_complete
          before_transition on: :init_refund, do: :before_init_refund
          after_transition on: :init_refund, do: :after_init_refund
          after_transition on: :complete_refund, do: :after_complete_refund
          after_transition on: :cancel_refund, do: :after_cancel_refund
          after_transition from: :pending, to: :canceled, do: :after_user_cancel
          after_transition on: :cancel do |order, transition|
            order.cancel_reason = transition.args.first
            order.after_cancel
          end
          around_transition on: :confirm do |order, transition, block|
            order.send(:check_is_paid_for_pay_online)
            if order.errors.blank?
              block.call
            end
          end
          around_transition on: :complete do |order, transition, block|
            order.send(:check_is_paid)
            if order.errors.blank?
              block.call
            end
          end
        end

        def extra_desc
        end

        def extra_info
        end

        def after_change_item_total_action
        end

        def note
          order_change_logs.place_log.try(:description) if order_change_logs.present?
        end

        def note=(new_note)
          if order_change_logs.present?
            place_log = order_change_logs.place_log
            place_log.update(description: new_note) if place_log.present?
          end
        end

        def before_init_refund
        end

        def after_init_refund
          self.pay_item_state = "unpaid"
          self.save
        end

        def after_complete_refund
          self.save
        end

        def after_cancel_refund
          self.pay_item_state = "paid"
          self.save
        end

        concerning :Modified do
          def modified_at
            updated_at + modify_version
          end

          def modify_time(time)
            return Time.parse('2000-01-01') if time.nil?
            time + modify_version
          end

          def modify_version
            1
          end
        end

        concerning :Place do
          def after_place
            init_platform_pay_item
            self.create_order_ext
            after_place_action
            save
            send_place_notification
            confirm if can_confirm? && need_auto_confirm_after_place?
            change_pay_item_to_paid(pay_items.first) if is_vip_card_pay? && user.present?
          end

          private
          def after_place_action
            current_vip.touch(:last_placed_at) if current_vip.present?
            update_stock_quantity(line_items)
            update_place_orders_count
          end

          def update_place_orders_count
            Shop.increment_counter(:placed_orders_count, shop_id)
            Branch.increment_counter(:placed_orders_count, branch_id)
            BaseUser.increment_counter(:placed_orders_count, base_user_id) if user.present?
          end

          def send_place_notification
            Notification::Event::Order::Placed.create_and_send_notification(order: self, operator_id: operator.try(:id))
          end

          def need_auto_confirm_after_place?
            false
          end
        end

        concerning :Confirm do
          def after_confirm
            touch :confirmed_at
            add_change_log(:order_confirm)
            after_confirm_action
            save
            send_confirm_notification
          end

          private
          def check_is_paid_for_pay_online
            # 对于堂点订单，可以吃完才付款，此种情况是可以确认的
            unless self.is_eat_in_hall?
              self.errors[:base] << "该订单尚未支付，需等待支付后才能进行进一步操作" if self.is_pay_online? && !self.paid?
            end
          end

          def after_confirm_action
          end

          def send_confirm_notification
            Notification::Event::Order::Confirmed.create_and_send_notification(order: self, operator_id: operator.try(:id)) unless ignore_notification
          end
        end

        concerning :Complete do
          def after_complete
            touch :completed_at
            add_change_log(:order_complete)
            after_complete_action
            save
            send_complete_notification
            create_promotion_event_for_order_complete
          end

          private
          def check_is_paid
            self.errors[:base] << "请先支付订单，再完成订单" if self.total > 0 && self.is_not_paid?
          end

          def after_complete_action
            update_sale_quantity
            self.vip_info.order_complete(self) if self.vip_info.present?
            self.credits_deduction.try(:complete)
            self.card_deduction.try(:complete)
            self.update_line_item_not_actual_amount
            self.update_combo_package_item_adjustments
            self.vip_info.increment!(:consume_times) if self.vip_info.present?
          end

          def send_complete_notification
            Notification::Event::Order::Completed.create_and_send_notification(order_id: self.id, operator_id: operator.try(:id)) unless ignore_notification
          end

          def create_promotion_event_for_order_complete
            # Promotion::Events::OrderPay.delay.create(order_id: self.id)
          end
        end

        concerning :Cancel do
          included do
            def self.cancel_reasons
              %w[货物售罄 地址无效 超出范围 无法配送 定单无效 其他原因]
            end
          end

          def after_cancel
            touch :canceled_at
            add_change_log(:order_cancel)
            self.pay_items.destroy_all
            update_pay_info
            self.reload_line_item_trace_points
            self.line_item_trace_points.each do |litp|
              litp.cancel
            end
            after_cancel_action
            save
            send_cancel_notification
          end

          private
          def after_cancel_action
            rollback_stock_quantity
            self.credits_deduction.try(:cancel)
            self.card_deduction.try(:cancel)
            self.coupon.try(:rollback_coupon)
          end

          def send_cancel_notification
            Notification::Event::Order::Canceled.create_and_send_notification(order: self, operator_id: operator.try(:id)) unless ignore_notification
          end
        end

        concerning :Pay do
          def get_amount_for_pay
            total
          end

          def after_pay
            after_pay_action
            send_pay_notification
            update_pay_items_not_actual_amount
            confirm if can_confirm? && need_auto_confirm_after_pay?
            complete if can_complete? && need_auto_complete_after_pay?
          end

          def default_pay_method
            :pay_on_face
          end

          def default_pay_method_name
            self.class.pay_method_name(self.default_pay_method)
          end

          private
          def after_pay_action
            Promotion::Events::OrderPay.delay.create(order_id: self.id) if self.promotion_event.blank?
          end

          def send_pay_notification
            Notification::Event::Order::Paid.delay_for(1.second).create_and_send_notification(order_id: self.id, operator_id: operator.try(:id)) unless ignore_notification
          end

          def need_auto_confirm_after_pay?
            false
          end

          def need_auto_complete_after_pay?
            false
          end
        end

        concerning :VipInfo do
          def current_vip
            self.user.present? ? self.user.vip_info : self.vip_info
          end

          def vip_card_no
            self.vip_info.try(:vip_no) if is_vip?
          end

          def vip_card_amount
            self.vip_info.try(:card_wallet).try(:amount) if is_vip?
          end

          def is_vip?
            vip_info.present? && !vip_info.is_default
          end

          def change_vip_info(vip_info)
            if self.vip_info_id.present? || self.base_user_id.present?
              base_user_id = self.base_user_id || self.vip_info.base_user.id
              BaseUser.decrement_counter(:placed_orders_count, base_user_id) if base_user_id.present?
            end
            vip_info.update(last_placed_at: self.placed_at)
            self.vip_info = vip_info
            self.user = vip_info.base_user
            self.vip_discount = vip_info.discount
            line_items.each(&:set_enjoy_vip_price)
            cancel_credits_deduction
            update_total_and_save
            BaseUser.increment_counter(:placed_orders_count, user.id) if self.user.present?
          end

          def unbind_vip_info
            return if self.vip_info_id.blank? && self.base_user_id.blank?
            self.vip_info = nil
            self.user = nil
            self.vip_discount = 1
            line_items.each(&:unset_enjoy_vip_price)
            adjustments.vip_discount.each(&:destroy)
            adjustments.enjoy_vip_price.each(&:destroy)
            cancel_credits_deduction
            update_total_and_save
            BaseUser.decrement_counter(:placed_orders_count, self.user.id) if self.user.present?
          end
        end

        concerning :Amount do
          # 没打折之前的订单合计
          def original_amount
            sum = 0
            sum += consume_amount
            sum += tax_total
            sum += self.adjustments.not_discount_amount
            sum += extra_amount
            sum.round(2)
          end

          # 折扣金额
          def discount_amount
            self.adjustments.discount_amount
          end

          # 消费合计
          def consume_amount
            line_items.item_total
          end

          def amount
            line_items.item_total
          end

          def extra_amount
            0
          end
        end

        concerning :Bill do
          def order_detail_in_bill(options={})
            # return nil string or array
            printer = options[:printer] || Printer::Normal.new(print_spec: (options[:print_spec] || "58"), use_scene: (options[:use_scene] || :webpos) )
            is_paid_bill = options[:is_paid_bill]
            is_product_bill = options[:is_product_bill]
            is_consume_bill = options[:is_consume_bill]
            is_reprint_bill = options[:is_reprint_bill]
            is_last_append_product_bill = options[:is_last_append_product_bill]
            order_change_log = options[:order_change_log]
            bill_operator = options[:bill_operator]

            return if !printer.concern_table(self)
            return if !printer.concern_line_item(self.line_items.active)

            if printer.use_scene.to_sym == :label
              BillTemplate::Order::LabelBill.new(order: self, printer: printer, order_change_log: order_change_log, bill_operator: bill_operator).render
            elsif printer.print_per_product?
              BillTemplate::Order::PerProductBill.new(order: self, printer: printer, order_change_log: order_change_log, bill_operator: bill_operator).render
            elsif printer.print_one_by_one?
              BillTemplate::Order::OneByOneBill.new(order: self, printer: printer, order_change_log: order_change_log, bill_operator: bill_operator).render
            elsif printer.is_webpos?
              if is_product_bill
                BillTemplate::Order::ProductBill.new(order: self, printer: printer, order_change_log: order_change_log, bill_operator: bill_operator).render
              elsif is_consume_bill
                BillTemplate::Order::ConsumeBill.new(order: self, printer: printer, order_change_log: order_change_log, bill_operator: bill_operator).render
              elsif is_last_append_product_bill
                BillTemplate::Order::AppendProductBill.new(order: self, printer: printer, bill_operator: bill_operator).render
              else
                BillTemplate::Order::Bill.new(order: self, printer: printer, bill_operator: bill_operator).render
              end
            elsif printer.is_guest?
              if is_eat_in_hall?
                if is_consume_bill
                  BillTemplate::Order::ConsumeBill.new(order: self, printer: printer, order_change_log: order_change_log, bill_operator: bill_operator).render
                else
                  BillTemplate::Order::ProductBill.new(order: self, printer: printer, order_change_log: order_change_log, bill_operator: bill_operator).render
                end
              elsif is_last_append_product_bill
                BillTemplate::Order::AppendProductBill.new(order: self, printer: printer, bill_operator: bill_operator).render
              else
                BillTemplate::Order::Bill.new(order: self, printer: printer, bill_operator: bill_operator).render
              end
            elsif printer.is_kitchen?
              BillTemplate::Order::ShortBill.new(order: self, printer: printer, order_change_log: order_change_log, bill_operator: bill_operator).render
            end
          end

          def order_detail_in_text(options={})
            Ddt::OrderFormat::Text.new(self).content(options)
          end

          def order_detail_in_html(options={})
            Ddt::OrderFormat::Html.new(self, options).content
          end

          def order_detail_in_sms
            # return a array
            Ddt::OrderFormat::Sms.new(self).content
          end
        end

        concerning :PrintRule do
          def webpos_printers
            self.branch.printers.use_in_webpos.active
          end

          def guest_printers
            self.branch.printers.use_in_guest.active
          end

          def need_notify_guest_printer_when_place?
            # Guest printer is deliver from webpos printer
            # So, Follow the webpos printer's rule
            !self.is_local_printed? && self.is_not_vip_card_pay?
          end

          def need_notify_webpos_printer_when_paid?
            !need_notify_guest_printer_when_place?
          end

          private
          def not_need_pay_online?
            self.is_not_pay_online? || self.get_amount_for_pay <= 0
          end
        end

        concerning :OrderChangeLog do
          def add_change_log(type, options={})
            type = :delete_itemable if type.to_sym == :subtract_itemable
            change_log = OrderService::OrderChangeLog.new(options.merge({type: "Ddt::OrderChangeLog::#{type.to_s.classify}", operator: operator, order: self}))
            self.order_change_logs.push(change_log)
            change_log
          end
        end

        concerning :RelatedOrder do
          def related_order
            OrderService::Order::Base.find(related_order_id) if related_order_id.present?
          end

          def related_order=(order)
            self.related_order_id = order.try(:id)
          end
        end

        concerning :ChangeLineItemPrice do
          def change_line_item_price(line_item_id, new_price)
            if new_price >= 0
              line_item = self.line_items.find(line_item_id)
              if line_item.enjoy_vip_price? || line_item.gift?
                self.errors[:base] << "该菜品已变动过价格，不允许改价"
              else
                line_item.change_price(new_price)
                update_total_and_save
              end
            else
              self.errors[:base] << "改价价格不能小于0"
            end
          end
        end

        concerning :ChangeLineItemWeight do
          def change_line_item_weight(line_item_id, new_weight)
            if new_weight > 0
              line_item = self.line_items.find(line_item_id)
              if line_item.is_variant_package?
                line_item.change_weight(new_weight)
                update_total_and_save
              else
                self.errors[:base] << '当前条目不支持改重量'
              end
            else
              self.errors[:base] << '重量不能小于0'
            end
          end
        end

        concerning :ValueChanged do
          def total_changed
          end
        end

        def can_user_cancel?
          self.is_pending?
        end

        def active?
          self.is_pending? || self.is_confirmed?
        end

        def after_user_cancel
          if operator.present? && operator == self.user
            operator.increase_continuous_cancel_order_count
          end
        end

        def is_first_order_of_user?
          self.user.present? && self.user.placed_orders_count == 1
        end

        def is_commented
          self.comment.present?
        end

        def all_managers
          self.branch.order_related_people
        end

        def allow_actions
          action_rel = {
              pending: [:confirm, :cancel],
            confirmed: [:complete, :cancel],
            completed: [],
               merged: [],
               refunding: [],
               refunded: [],
             canceled: []
          }
          if action_rel.keys.include?(self.state.to_sym)
            action_rel[self.state.to_sym]
          else
            raise "OrderState invliad: order_id: #{self.id}, state: #{self.state}"
          end
        end

        def evaluate_promotion?
          !self.is_FromWebpos? || branch.promotion_in_webpos?
        end

        def time_since_placed_at
          TimeUtil.label_of_second(current_time.to_i - self.placed_at.to_i)
        end

        def displayer
          OrderDisplay::Base.new(self)
        end
        delegate :order_info, :info_items, :short_addition_info, to: :displayer

        def reprint(target_ids=[], note='', operator=nil)
          if target_ids.present?
            Notification::Event::Order::Reprint.create_and_send_notification(order_id: self.id, note: note, printer_ids: target_ids.join(","), operator_id: operator.try(:id))
          end
        end

        def tick_account
          pay_items.with_pay_method.detect{|p| p.tick_for_account? }.try(:tick_account)
        end

        def as_api_json
          {
            id: id,
            number: number,
            type: type,
            type_name: type_name,
            state: state,
            state_name: state_name,
            item_count: item_count,
            item_total: item_total,
            adjustment_total: adjustment_total,
            total: total,
            pay_item_total: pay_item_total,
            tax_total: tax_total,
            amount_for_pay: amount_for_pay,
            pay_item_state: pay_item_state,
            pay_item_state_name: pay_item_state_name,
            pay_method: pay_method,
            pay_method_name: pay_method_name,
            anti_settlement: anti_settlement,
            vip_discount: vip_discount,
            cancel_reason: cancel_reason,
            placed_at: placed_at,
            confirmed_at: confirmed_at,
            completed_at: completed_at,
            canceled_at: canceled_at,
            paid_at: paid_at,
            created_at: created_at,
            updated_at: updated_at,
            branch_id: branch_id,
            shop_id: shop_id,
            base_user_id: base_user_id,
            delivery_name: delivery_name,
            delivery_phone: delivery_phone,
            delivery_address: delivery_address,
            table_name: table_name,
            table_zone_name: table_zone_name,
            guest_num: guest_num,
            food_number: food_number,
            line_items: line_items.map(&:as_api_json),
            pay_items: pay_items.map(&:as_api_json),
            adjustments: adjustments.map(&:as_api_json)
          }.compact
        end

      end
    end
  end
end
