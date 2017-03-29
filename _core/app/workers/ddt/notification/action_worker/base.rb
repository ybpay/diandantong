module Ddt
  class Notification
    module ActionWorker
      class Base
        include Sidekiq::Worker
        sidekiq_options :retry => 5, :queue => :default, :expires_in => 8.hours
        def perform(event_attributes, action_attributes)
          event = Ddt::NotificationEvent.init(event_attributes)
          action = Ddt::NotificationAction.init(action_attributes.merge(notification_event: event))
          action.perform if action.can_perform?
        end
      end
    end
  end
end
