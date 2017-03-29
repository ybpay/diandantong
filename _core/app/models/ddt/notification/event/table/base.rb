module Ddt
  class Notification
    module Event
      module Table
        class Base < Ddt::NotificationEvent
          belongs_to :branch
        end
      end
    end
  end
end
