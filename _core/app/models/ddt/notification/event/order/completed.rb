module Ddt
  class Notification
    module Event
      module Order
        class Completed < Ddt::Notification::Event::Order::Base
          # 订单完成
          def notification_targets
            targets = []
            targets << order.user
            targets << branch
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            {
              user:       [:weixin],
              phone_user: [],
              web_user:   [:email],
              branch: [:cloud_server]
            }[target_type]
          end
        end
      end
    end
  end
end
