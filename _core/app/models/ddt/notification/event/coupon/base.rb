module Ddt
  class Notification
    module Event
      module Coupon
        class Base < Ddt::NotificationEvent
          belongs_to :base_coupon, class_name: "Ddt::BaseCoupon"
          belongs_to_order
          set_from :base_coupon
          def notification_targets
            targets = []
            targets << base_coupon.user
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            {
              user: [:weixin]
            }[target_type]
          end
        end
      end
    end
  end
end
