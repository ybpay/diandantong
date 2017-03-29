module Ddt
  class Notification
    module Action
      class Webpos < Ddt::NotificationAction
        alias_method :account, :target
        def perform
          view = Ddt::Notification::View::Webpos.new(event, target)
          message = view.render
          channel = Ddt::WebposNotify.channel(account.id)
          if message.is_a? Array
            message.each {|msg| publish_msg(channel, msg)}
          else
            publish_msg(channel, message)
          end

        end

        private

        def publish_msg(channel, msg)
          return if msg.blank?
          PrivatePub.publish_to(channel, msg: msg)
        end

      end
    end
  end
end
