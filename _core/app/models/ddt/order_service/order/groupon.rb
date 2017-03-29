module Ddt
  module OrderService
    module Order
      class Groupon < Order::Base
        has_many :base_coupons, class_name: "Ddt::BaseCoupon", foreign_key: :bought_from_order_id

        def need_auto_confirm_after_pay?
          true
        end

        def need_auto_complete_after_pay?
          true
        end

        def evaluate_promotion?
          false
        end

        def after_complete_action
          if user.present?
            self.line_items.each do |line_item|
              line_item.quantity.times do
                line_item.itemable.send_coupon_to_user(self.user, :order, self)
              end
            end
          end
          super
        end

        # todo worker
        # after_find :auto_cancel
        # def auto_cancel
        #   if has_attribute?(:placed_at) && has_attribute?(:state) && has_attribute?(:pay_item_state)
        #     if self.placed_at && self.placed_at < 20.minutes.ago && self.pending? && self.pay_item_state.to_sym != :paid
        #       self.cancel!
        #     end
        #   end
        # end
        concerning :PrintRule do
          def need_notify_guest_printer_when_place?
            super && not_need_pay_online?
          end
        end

        def pay_method_blacklist
          [:pay_on_arrive, :pay_on_receive]
        end
      end
    end
  end
end
