module Ddt
  class Notification
    module Event
      module Coupon
        class CancelApplyingRefund < Ddt::Notification::Event::Coupon::Base


          def notification_targets
            targets = []
            targets << shop.accounts.bosses_and_workers
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            {
              account: [:backend, :system_weixin]
            }[target_type]
          end

        end
      end
    end
  end
end
