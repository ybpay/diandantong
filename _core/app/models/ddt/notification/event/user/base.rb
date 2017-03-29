module Ddt
  class Notification
    module Event
      module User
        class Base < Ddt::NotificationEvent
          belongs_to :user, class_name: 'Ddt::BaseUser'
          set_from :user
        end
      end
    end
  end
end
