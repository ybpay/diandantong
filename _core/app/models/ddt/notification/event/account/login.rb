module Ddt
  class Notification
    module Event
      module Account
        class Login < Ddt::NotificationEvent

          belongs_to :account
          attribute :token_hash
          set_from :account

          def notification_targets
            [account]
          end

          def action_types_of_target(target_type, target)
            {
              account:  [:app]
            }[target_type]
          end
        end
      end
    end
  end
end
