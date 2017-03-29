module Ddt
  class Notification
    module Event
      module Order
        class CallWaiter < Ddt::Notification::Event::Order::Base
          attribute :service_name
          def notification_targets
            targets = []
            targets << order.all_managers
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            account_action_types = [:webpos]
            if target_type == :account
              [:backend, :system_weixin, :app].each do |action|
                account_action_types << action if target.notification_receive_setting.need_notify?(:order_call_waiter, action)
              end
            end
            {
              account: account_action_types
            }[target_type]
          end
        end
      end
    end
  end
end
