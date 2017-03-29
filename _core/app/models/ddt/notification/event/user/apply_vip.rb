module Ddt
  class Notification
    module Event
      module User
        class ApplyVip < Ddt::Notification::Event::User::Base

          def notification_targets
            targets = []
            targets << shop.accounts.boss
            targets << user
            targets.flatten
          end

          def action_types_of_target(target_type, target)
            {
              #account:    [:backend, :system_weixin],
              account:    [:backend],
              user: [:weixin]
            }[target_type]
          end

        end
      end
    end
  end
end
