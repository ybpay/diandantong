module Ddt
  class Notification
    module Event
      module User
        class CardWalletChange < Ddt::Notification::Event::User::Base
          belongs_to :wallet_log

          def notification_targets
            targets = [user]
          end

          def action_types_of_target(target_type, target)
            {
              user: [:weixin ,:sms]
            }[target_type]
          end

        end
      end
    end
  end
end
