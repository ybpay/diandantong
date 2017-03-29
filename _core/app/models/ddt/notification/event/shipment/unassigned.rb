module Ddt
  class Notification
    module Event
      module Shipment
        class Unassigned < Ddt::Notification::Event::Shipment::Base
          attribute :delivery_man_id
          # 取消配送分配
          def notification_targets
            targets = []
            targets << pre_delivery_man
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            account_action_types = []
            if target_type == :account
              [:system_weixin, :app].each do |action|
                account_action_types << action if target.notification_receive_setting.need_notify?(:shipment_unassigned, action)
              end
            end
            {
              account:    account_action_types
            }[target_type]
          end

          private
            def pre_delivery_man
              shop.accounts.with_deleted.find(delivery_man_id)
            end
        end
      end
    end
  end
end
