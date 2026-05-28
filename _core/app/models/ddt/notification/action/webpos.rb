module Ddt
  class Notification
    module Action
      class Webpos < Ddt::NotificationAction
        alias_method :account, :target
        def perform
          view = Ddt::Notification::View::Webpos.new(event, target)
          message = view.render
          if message.is_a? Array
            message.each { |msg| publish_msg(account, msg) }
          else
            publish_msg(account, message)
          end
        end

        private

        def publish_msg(account, msg)
          return if msg.blank?
          WebposChannel.broadcast_to(account, msg)
        end
      end
    end
  end
end
