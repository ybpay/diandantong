module Ddt
  class Notification
    module Event
      module Order
        class Hasten < Ddt::Notification::Event::Order::Base
          attribute :line_item_id
          attribute :track_from
          # 订单催单
          def notification_targets
            targets = []
            printer_use_scene = [:webpos]
            printer_use_scene << :kitchen if order.is_eat_in_hall? || order.is_fastfood?
            targets << order.branch.printers.where(use_scene: printer_use_scene).active
            targets << order.all_managers
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            account_action_types = \
              case self.track_from
              when Ddt::TrackFrom::WEBPOS then [:backend, :webpos]
              when Ddt::TrackFrom::WECHAT then [:backend, :webpos, :system_weixin, :app]
              else
                [:backend, :webpos, :app]
              end
            if target_type == :account
              [:backend, :system_weixin, :app].each do |action|
                account_action_types.delete(action) unless target.notification_receive_setting.need_notify?(:order_hasten, action)
              end
            else
              account_action_types = [:webpos]
            end
            {
              account: account_action_types,
              printer: [:printer]
            }[target_type]
          end
        end
      end
    end
  end
end
