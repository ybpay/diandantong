module Ddt
  class Notification
    module Action
      class Backend < Ddt::NotificationAction
        alias_method :account, :target
        def perform
          view = Ddt::Notification::View::Backend.new(event, target)
          msg = view.render
          channel = "/messages/accounts/#{account.id}"
          PrivatePub.publish_to(channel, msg: msg)
        end
      end
    end
  end
end
