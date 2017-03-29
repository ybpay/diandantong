module Ddt
  class Notification
    module Event
      module Order
        class RequestPay < Ddt::Notification::Event::Order::Base
          attribute :pay_method_name

          def notification_targets
            targets = []
            targets << order.webpos_printers
            targets << order.all_managers
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            account_action_types = [:webpos]
            if target_type == :account
              [:backend, :app].each do |action|
                account_action_types << action if target.notification_receive_setting.need_notify?(:order_request_pay, action)
              end
            else
              account_action_types = [:webpos]
            end
            {
              account: account_action_types,
              printer:    [:printer]
            }[target_type]
          end
        end
      end
    end
  end
end
