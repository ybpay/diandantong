module Ddt
  class Notification
    module Action
      class Printer < Ddt::NotificationAction
        alias_method :printer, :target
        def perform
          view = Ddt::Notification::View::Printer.new(event, target)
          content = view.render
          uuid = "#{target.id}-#{event.uuid}" 
          printer.print(content, uuid: uuid)
        end
      end
    end
  end
end