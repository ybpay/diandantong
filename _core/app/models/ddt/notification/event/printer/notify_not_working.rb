module Ddt
  class Notification
    module Event
      module Printer
        class NotifyNotWorking < Ddt::NotificationEvent
          belongs_to :branch
          belongs_to :printer
          attribute :last_print_success_at

          def notification_targets
            if branch.present?
              targets = branch.order_related_people
            else
              targets = []
            end
            targets.flatten.compact.uniq
          end

          def action_types_of_target(target_type, target)
            {
                account: [:webpos, :backend]
            }[target_type]
          end

        end
      end
    end
  end
end
