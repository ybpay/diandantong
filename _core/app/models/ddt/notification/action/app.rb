module Ddt
  class Notification
    module Action
      class App < Ddt::NotificationAction
        def perform
          view = Ddt::Notification::View::App.new(event, target)
          message = view.render
          channels = target.push_channels.active.uniq
          Ddt::JPushClient.batch_device(message, channels)
        end
      end
    end
  end
end
