module Ddt
  class Notification
    module Event
      module Table
        class CancelCheckOut < Ddt::Notification::Event::Table::Base
          belongs_to :table
          belongs_to_order
          attribute :order_id
          set_from :table

          def notification_targets
            targets = []
            targets << branch.order_related_people
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            {
              account:    [:webpos],
              printer:    [:printer]
            }[target_type]
          end
        end
      end
    end
  end
end
