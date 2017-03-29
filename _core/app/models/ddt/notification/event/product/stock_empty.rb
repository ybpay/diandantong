module Ddt
  class Notification
    module Event
      module Product
        class StockEmpty < Ddt::NotificationEvent
          belongs_to :branch
          belongs_to :variant
          set_from :variant

          def notification_targets
            [
                shop.boss,
                branch.managers.workers,
                branch.managers.boss,
                branch.printers.use_in_webpos.active
            ].flatten.uniq
          end

          def action_types_of_target(target_type, target)
            account_action_types = [:webpos]
            if target_type == :account
              [:backend, :app].each do |action|
                account_action_types << action if target.notification_receive_setting.need_notify?(:product_stock_empty, action)
              end
            else
              account_action_types = [:webpos]
            end
            {
                # :system_weixin 需要模板
                account:  account_action_types,
                printer:  [:printer]
            }[target_type]
          end
        end
      end
    end
  end
end
