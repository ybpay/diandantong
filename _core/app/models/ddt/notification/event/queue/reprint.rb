module Ddt
  class Notification
    module Event
      module Queue
        class Reprint < Ddt::Notification::Event::Queue::Base
          def notification_targets
            targets = []
            targets << branch.printers.use_in_queue.active
            targets.flatten.compact.uniq
          end

          def action_types_of_target(target_type, target)
            {
              printer: [:printer]
            }[target_type]
          end
        end
      end
    end
  end
end
