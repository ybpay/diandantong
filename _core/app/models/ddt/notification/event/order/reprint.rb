module Ddt
  class Notification
    module Event
      module Order
        class Reprint < Ddt::Notification::Event::Order::Base

          attribute :note
          attribute :printer_ids

          def notification_targets
            targets = []
            targets << Ddt::Printer.find(printer_ids.split(","))
            targets.flatten.compact
          end

          def action_types_of_target(target_type, target)
            {
              printer:    [:printer]
            }[target_type]
          end
        end
      end
    end
  end
end
