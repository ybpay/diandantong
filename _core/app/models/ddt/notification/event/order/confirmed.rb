module Ddt
  class Notification
    module Event
      module Order
        class Confirmed < Ddt::Notification::Event::Order::Base

          # 订单确认
          def notification_targets
            targets = []
            # 外卖、堂点、快餐
            if order.is_delivery? || order.is_eat_in_hall? || order.is_fastfood?
              targets << order.branch.printers.use_in_kitchen.active
            end
            targets << order.user
            targets << order.all_managers
            # 外卖订单如果是主动抢单模式，应该给配送员方便抢单
            if order.is_delivery?
              targets << order.branch.deliverymans if assign_mode_is_active?
            end

            #今天可以烹饪
            # if order.can_cook_today?
            #   targets << order.branch.managers.cooks
            #   targets << order.branch.managers.chefs
            # end

            #标签打印机
            targets << order.branch.printers.use_in_label.active

            targets << branch
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            # 是主动抢单模式，就得通知配送员抢单
            account_action_types = []
            if order.is_delivery? and target_type == :account and target.is_deliveryman? and assign_mode_is_active?
              account_action_types.concat [:system_weixin, :app]
            end

            if !can_notify?
              account_action_types.concat [:webpos]
            elsif order.is_FromWebpos?
              account_action_types.concat [:backend, :webpos, :system_weixin, :email]
            else
              account_action_types.concat [:backend, :webpos, :system_weixin, :email, :app]
            end

            if target_type == :account
              [:backend, :system_weixin, :email, :app].each do |action|
                account_action_types.delete(action) unless target.notification_receive_setting.need_notify?(:order_confirmed, action)
              end
            else
              account_action_types = [:webpos]
            end

            {
              account:    account_action_types.uniq,
              user:       [:weixin],
              phone_user: [],
              web_user:   [:email],
              printer:    [:printer],
              branch: [:cloud_server]
            }[target_type]
          end

          private
            def can_notify?
              (order.is_pay_online? && order.get_amount_for_pay > 0)
            end

            def assign_mode_is_active?
              order.branch.delivery_setting.assign_mode == 'active'
            end

        end
      end
    end
  end
end
