module Ddt
  class Notification
    module Event
      module Order
        class Canceled < Ddt::Notification::Event::Order::Base
          # 订单取消
          def notification_targets
            targets = []
            targets << order.user
            targets << order.all_managers
            targets << order.branch.managers.cooks
            targets << order.branch.managers.chefs
            targets << branch
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            account_action_types = [:webpos]
            if target_type == :account
              [:backend, :system_weixin, :email, :app].each do |action|
                account_action_types << action if target.notification_receive_setting.need_notify?(:order_canceled, action)
              end
            end
            {
              account: account_action_types,
              user:       [:weixin],
              phone_user: [],
              web_user:   [:email],
              branch: [:cloud_server]
            }[target_type]
          end
        end
      end
    end
  end
end
