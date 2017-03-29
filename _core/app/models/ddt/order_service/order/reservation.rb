module Ddt
  module OrderService
    module Order
      class Reservation < Order::Base
        has_one :reservation_info, foreign_key: :reservation_order_id
        belongs_to_order name: :related_order
        acts_as_type :prepayment_type, [:prepay_for_table, :prepay_for_order], %W[预订订座预付 预订下单预付]
        acts_as_type :reservation_gender, [:male, :female], %W[先生 女士]

        def displayer
          OrderDisplay::Reservation.new(self)
        end

        alias_method :name, :reservation_name
        alias_method :phone, :reservation_phone
        alias_method :gender, :reservation_gender
        alias_method :gender_name, :reservation_gender_name
        alias_method :table_zone_name, :reservation_table_zone_name
        alias_method :reservation_time_point_str, :reservation_time_point_display
        def reservation_date_str
          self.reservation_date.try(:strftime, "%F")
        end
        delegate :reservation_time_point, :table_zone, to: :reservation_info
        alias_method :reservation_table_zone, :table_zone

        def reservation_time_info
          "#{reservation_table_zone_name} #{reservation_table_name} #{reservation_date_str} #{reservation_time_point_display}"
        end

        def reservation_customer_info
          "#{self.reservation_name} #{self.reservation_gender_name}(#{self.reservation_phone})"
        end

        def reservation_note
          "已转为堂点 #{self.related_order.number}" if self.related_order.present?
        end

        def extra_info
          self.reservation_customer_info
        end

        def extra_desc
        end

        def evaluate_promotion?
          false
        end

        def after_place_action
          self.create_exchange_code unless self.is_pay_online?
          if self.user.present?
            self.user.update(
              reservation_name: self.reservation_name,
              reservation_phone: self.reservation_phone,
              reservation_gender: self.reservation_gender
            )
          end
          super
        end

        def after_pay_action
          self.create_exchange_code if self.is_pay_online?
          super
        end

        def after_cancel
          super
          self.reservation_info.update(active: false)
        end

        def need_auto_confirm_after_place?
          is_FromWebpos? || is_FromApp?
        end

        def need_auto_confirm_after_place?
          is_FromWechat? && is_pay_online?
        end

        def get_amount_for_pay
          if is_prepay_for_table?
            total
          elsif is_prepay_for_order?
            total * (reservation_info.table_zone.try(:reservation_price_percent) / 100.0)
          end
        end

        concerning :PrintRule do
          def need_notify_guest_printer_when_place?
            super && not_need_pay_online?
          end
        end

        def can_append_itemable?(need_errors: false)
          if need_errors
            self.errors[:base] << "该订单已完成或已结束,不能加减菜" unless active?
            self.errors[:base] << "该订单已支付,不能加减菜"       unless is_not_paid?
            self.errors[:base] << "预订订座不能加减菜"           unless is_prepay_for_order?
            self.errors.blank?
          else
            active? && is_not_paid? && is_prepay_for_order?
          end
        end
        alias_method :can_subtract_itemable?, :can_append_itemable?

        concerning :ChangeToEatInHall do
          def can_change_to_eat_in_hall?
            self.is_prepay_for_order? && self.active? && self.related_order_id.blank? && self.paid?
          end

          def change_to_eat_in_hall(table_id, note:"")
            if self.can_change_to_eat_in_hall?
              table = self.branch.tables.find(table_id)
              if table.idle?
                transaction do
                  line_itemables = self.line_items.map(&:line_itemable)
                  cart = OrderService::Cart::EatInHall.new(
                    branch: self.branch,
                    table: table,
                    note: note,
                    user: self.user,
                    line_itemables: line_itemables,
                    waiter: self.operator,
                    track_from: :FromWebpos,
                  )
                  order = cart.place
                  order.adjust(reason: :prepay_for_reservation_order, amount: -self.amount_for_pay)
                  self.update(related_order: order)
                  order.update(related_order: self)
                  order.update_total
                  OrderService::Order::Base.batch_update(self, order)
                  self.reload
                  self.confirm if self.can_confirm?
                  self.complete if self.can_complete?
                  order.reload
                end
              else
                self.errors[:base] << "选择的桌台不是空闲状态"
                false
              end
            else
              self.errors[:base] << "预订定座不能转为堂点订单" unless self.is_prepay_for_order?
              self.errors[:base] << "订单状态不能转为堂点订单" unless self.active?
              self.errors[:base] << "订单已经转为堂点订单" unless self.related_order_id.blank?
              self.errors[:base] << "订单未支付" unless self.paid?
              false
            end
          end
        end

        concerning :BindTable do
          def bind_table(table)
            if reservation_info.table.blank? && reservation_time_point.present? && table.can_reservation?(reservation_date.to_date, reservation_time_point)
              transaction do
                reservation_info.update(table: table)
                update(reservation_table_name: table.name)
                save
                send_bind_table_message(table)
                true
              end
            else
              self.errors[:base] << "该订单预订时间缺失" if self.reservation_time_point.blank?
              self.errors[:base] << "该订单已经绑定桌台" if self.table.present?
              self.errors[:base] << "该桌台已被预订， 不能绑定" if self.reservation_time_point.present? && !table.can_reservation?(reservation_date.to_date, reservation_time_point)
              false
            end
          end

          private
          def send_bind_table_message(table)
            body = "您在#{branch.name}的预订订单#{self.number}已绑定到桌台 #{table.name_with_zone}"
            if Rails.env.production?
              message = Ddt::ShortMessage.wrap_custom_message_to_send(shop, phone, body)
              message.save
            end
            if self.user.present?
              shop.notify_to(self.user, {
                title: body,
                description: self.order_detail_in_text,
                url: self.weixin_show_url
              })
            end
          end
        end

        concerning :Exchange do
          included do
            include Exchangeable

            def exchange_detail
              order_detail_in_html
            end

            def can_exchange?(branch)
              self.branch == branch && !exchanged?
            end
          end
        end

        concerning :Invitation do
          included do
            has_many :invitation_order_guests
            has_many :invitation_order_agree_guests, ->{agree}, class_name: 'Ddt::InvitationOrderGuest'
            has_many :invitation_order_disagree_guests, ->{disagree}, class_name: 'Ddt::InvitationOrderGuest'
            url_method_for :invitation_show
          end

          def agree_guests
            invitation_order_agree_guests.includes(:guest).map(&:guest)
          end

          def disagree_guests
            invitation_order_disagree_guests.includes(:guest).map(&:guest)
          end

          def invitation_show_path
            "weixin/shops/#{self.shop_id}/order?_ng_path=/branches/#{self.branch_id}/orders/invitation/#{self.id}"
          end
        end

        def update_reservation_info(params={})
          transaction do
            self.reservation_info.update(params.slice(:name, :phone, :gender))
            self.note = params[:note]
            self.reservation_name   = reservation_info.name
            self.reservation_phone  = reservation_info.phone
            self.reservation_gender = reservation_info.gender
            self.save
          end
        end

        def default_pay_method
          :pay_on_arrive
        end

        def pay_method_blacklist
          [:pay_on_receive]
        end

        private
        def check_is_paid
          return if self.related_order_id.present?
          super
        end
      end
    end
  end
end
