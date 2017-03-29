module Ddt
  class Notification
    module Event
      module Order
        class CallCustomer < Ddt::Notification::Event::Order::Base
          def notification_targets
            targets = []
            targets << order.user
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
