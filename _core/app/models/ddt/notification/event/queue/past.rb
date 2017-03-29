module Ddt
  class Notification
    module Event
      module Queue
        class Past < Ddt::Notification::Event::Queue::Base
          # 排队过号
          def notification_targets
            targets = super
            targets << branch.managers
            targets << branch.shop.accounts.boss
            targets << branch
            targets.flatten.compact.uniq
          end

          def action_types_of_target(target_type, target)
            if target_type == :account && target.notification_receive_setting.need_notify?(:queue_past, :app)
              account_action_types = [:app, :webpos]
            else
              account_action_types = [:webpos]
            end
            {
              account: account_action_types,
              branch: [:cloud_server]
            }[target_type]
          end

        end
      end
    end
  end
end
