module Ddt
  class Notification
    module Event
      module Queue
        class Notify < Ddt::Notification::Event::Queue::Base
          # 排队通知
        end
      end
    end
  end
end
