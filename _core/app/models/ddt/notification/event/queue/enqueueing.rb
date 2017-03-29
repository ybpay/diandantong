module Ddt
  class Notification
    module Event
      module Queue
        class Enqueueing < Ddt::Notification::Event::Queue::Base
          # 排队入队
          def notification_targets
            targets = []
            targets << guest_queue.user
            targets << branch.managers
            targets << branch.shop.accounts.boss
            targets << branch.printers.use_in_queue.active unless guest_queue.is_local_printed?
            targets << branch
            targets.flatten.compact.uniq
          end

          def action_types_of_target(target_type, target)
            account_action_types = [:app, :webpos]
            account_action_types.delete(:app) if guest_queue.is_FromApp?
            account_action_types.delete(:webpos) if guest_queue.is_FromWebpos?
            if target_type == :account
              account_action_types.delete(:app) unless target.notification_receive_setting.need_notify?(:queue_enqueueing, :app)
            else
              account_action_types = account_action_types.include?(:webpos) ? [:webpos] : []
            end
            {
              user: [:weixin],
              account: account_action_types,
              printer: [:printer],
              branch: [:cloud_server]
            }[target_type]
          end

        end
      end
    end
  end
end
