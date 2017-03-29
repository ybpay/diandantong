module Ddt
  class Notification
    module Event
      module Table
        class Opened < Ddt::Notification::Event::Table::Base
          # 开台
          belongs_to :table
          set_from :table
          def notification_targets
            targets = []
            targets << branch.order_related_people if branch.present?
            targets << branch
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            account_action_types = [:webpos]
            if target_type == :account
              [:backend, :app].each do |action|
                account_action_types << action if target.notification_receive_setting.need_notify?(:table_opened, action)
              end
            end
            {
              account:    account_action_types,
              printer:    [:printer],
              branch:     [:cloud_server]
            }[target_type]
          end
        end
      end
    end
  end
end
