module Ddt
  class Notification
    module Event
      module Invitation
        class Accepted < Ddt::Notification::Event::Invitation::Base

          def notification_targets
            targets = []
            targets << inviter
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
