module Ddt
  class Notification
    module Event
      module OrderChange
        class AppendItemable < Ddt::Notification::Event::OrderChange::Base
          attribute :is_local_printed
          # 追加商品
          def notification_targets
            targets = []
            targets << order.guest_printers unless is_local_printed
            if order.state.to_sym == :pending
              # 未确认的订单加减菜不通知厨房
              targets << order.branch.printers.use_in(:webpos).active
              targets << order.all_managers
            else
              targets << order.branch.printers.use_in(:kitchen, :label).active
              targets << order.all_managers
              targets << order.branch.managers.cooks
              targets << order.branch.managers.chefs
            end
            targets << branch
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            account_action_types = [:webpos]
            if target_type == :account
              [:backend, :app, :email].each do |action|
                account_action_types << action if target.notification_receive_setting.need_notify?(:order_change_append_itemable, action)
              end
            else
              account_action_types = [:webpos]
            end
            {
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
