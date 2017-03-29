module Ddt
  class Notification
    module Event
      module Shift
        class Base < Ddt::NotificationEvent
          belongs_to :branch
          belongs_to :shift
          set_from :branch
          def notification_targets
            targets = []
            targets << branch
            targets << branch.order_related_people
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            {
                account: [:webpos],
                branch:  [:cloud_server]
            }[target_type]
          end
        end
      end
    end
  end
end
