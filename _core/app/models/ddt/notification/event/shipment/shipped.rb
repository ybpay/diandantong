module Ddt
  class Notification
    module Event
      module Shipment
        class Shipped < Ddt::Notification::Event::Shipment::Base
          # 配送完成
          def notification_targets
            targets = []
            targets << order.user
            targets << order.shop.boss
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            account_action_types = []
            if target_type == :account
              [:system_weixin, :app].each do |action|
                account_action_types << action if target.notification_receive_setting.need_notify?(:shipment_shipped, action)
              end
            end
            {
              account:    account_action_types,
              user:       [:weixin],
              phone_user: [],
              web_user:   [:email]
            }[target_type]
          end
        end
      end
    end
  end
end
