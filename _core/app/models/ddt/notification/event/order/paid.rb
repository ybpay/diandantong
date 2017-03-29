module Ddt
  class Notification
    module Event
      module Order
        class Paid < Ddt::Notification::Event::Order::Base
          # 订单支付
          def notification_targets
            targets = []
            targets << order.webpos_printers if order.need_notify_webpos_printer_when_paid?
            targets << order.user
            targets << order.all_managers
            targets << branch
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            account_action_types = [ :webpos, :backend, :system_weixin, :email ]
            account_action_types << :app unless order.is_recharge?
            if target_type == :account
              [:backend, :system_weixin, :app, :email].each do |action|
                account_action_types.delete(action) unless target.notification_receive_setting.need_notify?(:order_paid, action)
              end
            else
              account_action_types = [:webpos]
            end
            {
              account:    account_action_types,
              user:       [:weixin],
              phone_user: [],
              web_user:   [:email],
              printer:    [:printer],
              branch: [:cloud_server]
            }[target_type]
          end
        end
      end
    end
  end
end
