module Ddt
  class Notification
    module Event
      module User
        class CreditsWalletChange < Ddt::Notification::Event::User::Base
          belongs_to :wallet_log

          def notification_targets
            targets = [user]
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
