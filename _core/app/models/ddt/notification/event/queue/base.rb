module Ddt
  class Notification
    module Event
      module Queue
        class Base < Ddt::NotificationEvent
          belongs_to :branch
          belongs_to :guest_queue
          set_from :guest_queue
          def notification_targets
            targets = []
            targets << guest_queue.user
            targets.flatten.compact.uniq
          end

          def action_types_of_target(target_type, target)
            {
              user: [:weixin],
              account: [:app]
            }[target_type]
          end
        end
      end
    end
  end
end
