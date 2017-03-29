module Ddt
  module OrderService
    module Order
      class Fastfood < Order::Base
        include OrderService::Order::Concern::Hastenable
        include OrderService::Order::Concern::CallWaiter

        def displayer
          OrderDisplay::Fastfood.new(self)
        end

        def need_auto_confirm_after_pay?
          true
        end

        def need_auto_complete_after_pay?
          # !(is_FromWechat? && is_pay_online?)
          false
        end

        def extra_info
            "牌号 #{self.food_number}"
        end

        def extra_desc
        end

        def can_append_itemable?(need_errors: false)
          if need_errors
            self.errors[:base] << "该订单已完成或已结束,不能加减菜" unless active?
            self.errors[:base] << "该订单已支付,不能加减菜" unless is_not_paid?
            self.errors.blank?
          else
            active? && is_not_paid?
          end
        end
        alias_method :can_subtract_itemable?, :can_append_itemable?

        concerning :Modified do
          def modified_at
            [modify_time(updated_at), modify_time(last_hasten_at), modify_time(last_call_waiter_at)].max
          end
        end

        concerning :CallCustomer do
          def call_customer
            Notification::Event::Order::CallCustomer.create_and_send_notification(order: self)
          end
        end

        concerning :Message do
          def hasten_extra_message
            "牌号#{self.food_number}"
          end

          def call_waiter_message(service_name)
            "牌号#{self.food_number} 呼叫服务员 #{service_name}"
          end
        end

        concerning :PrintRule do
          def need_notify_guest_printer_when_place?
            super && is_not_FromWebpos? && not_need_pay_online?
          end

          def need_notify_webpos_printer_when_paid?
            !self.is_local_printed?
          end
        end

        def pay_method_blacklist
          [:pay_on_arrive, :pay_on_receive]
        end
      end
    end
  end
end
