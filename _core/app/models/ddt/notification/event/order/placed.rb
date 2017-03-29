module Ddt
  class Notification
    module Event
      module Order
        class Placed < Ddt::Notification::Event::Order::Base
          # 订单下单
          def notification_targets
            targets = []
            targets << order.guest_printers if order.need_notify_guest_printer_when_place?
            targets << order.user
            targets << order.all_managers
            targets << branch
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            if !order.need_notify_guest_printer_when_place?
              # 该种情况仍需通知 webpos 更新状态
              account_action_types = [:webpos]
            elsif order.is_FromWebpos?
              account_action_types = [:backend, :webpos, :sms, :system_weixin, :email]
            else
              account_action_types = [:backend, :webpos, :sms, :system_weixin, :email, :app]
            end

            if target_type == :account
              [:backend, :sms, :system_weixin, :email, :app].each do |action|
                account_action_types.delete(action) unless target.notification_receive_setting.need_notify?(:order_placed, action)
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
