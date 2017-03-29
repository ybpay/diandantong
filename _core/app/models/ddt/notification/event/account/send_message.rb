module Ddt
  class Notification
    module Event
      module Account
        class SendMessage < Ddt::NotificationEvent
          belongs_to :system_message, class_name: 'Ddt::SystemMessage'
          set_from :system_message, target: [:account, :shop]

          def notification_targets
            [system_message.account]
          end

          def action_types_of_target(target_type, target)
            {
              account: [:app, :system_weixin]
            }[target_type]
          end
        end
      end
    end
  end
end
