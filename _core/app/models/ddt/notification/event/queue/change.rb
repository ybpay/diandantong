module Ddt
  class Notification
    module Event
      module Queue
        class Change < Ddt::Notification::Event::Queue::Base
          attribute :front_guest_number
          # 排队变化
          def action_types_of_target(target_type, target)
            {
              user: [:weixin]
            }[target_type]
          end

          def can_perform?
            num = self.front_guest_number
            num.nil? || num == guest_queue.guest_num_at_front
          end
        end
      end
    end
  end
end