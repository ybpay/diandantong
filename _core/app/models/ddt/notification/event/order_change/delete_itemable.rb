module Ddt
  class Notification
    module Event
      module OrderChange
        class DeleteItemable < Ddt::Notification::Event::OrderChange::Base

          # 删减商品
          def notification_targets
            targets = []
            if order.state.to_sym != :pending
              targets << order.branch.printers.use_in(:kitchen, :label).active
              targets << order.branch.managers.cooks
              targets << order.branch.managers.chefs
            end
            targets << order.user
            targets << order.all_managers
            targets << branch
            # targets << order.guest_printers if order.need_notify_guest_printer_when_place?
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            account_action_types = [:webpos]
            if target_type == :account
              [:backend, :app, :email].each do |action|
                account_action_types << action if target.notification_receive_setting.need_notify?(:order_change_delete_itemable, action)
              end
            else
              account_action_types = [:webpos]
            end
            {
              user:       [:weixin],
              account:    account_action_types,
              printer:    [:printer],
              branch: [:cloud_server]
            }[target_type]
          end

        end
      end
    end
  end
end
