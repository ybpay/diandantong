module Ddt
  class Notification
    module Event
      module Table
        class Merged < Ddt::Notification::Event::Table::Base

          # 并台
          belongs_to_order
          belongs_to_order name: :to_order
          belongs_to_order name: :from_order
          belongs_to_order_change_log
          attribute :order_id, :to_order_id, :from_order_id, :order_change_log_id
          set_from :order_change_log, targets: [:branch_id, :shop_id, :order]

          def notification_targets
            targets = []
            targets << order.all_managers
            targets << order.branch.printers.use_in(:webpos).active
            targets << order.branch.printers.use_in(:kitchen).active
            targets << branch
            targets.flatten
          end

          def action_types_of_target(target_type, target)
            account_action_types = [:webpos]
            if target_type == :account
              [:backend, :system_weixin, :app].each do |action|
                account_action_types << action if target.notification_receive_setting.need_notify?(:table_merged, action)
              end
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
