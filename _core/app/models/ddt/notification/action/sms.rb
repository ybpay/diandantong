module Ddt
  class Notification
    module Action
      class Sms < Ddt::NotificationAction
        def perform
          view = Ddt::Notification::View::Sms.new(event, target)
          to = target.try(:phone)
          if to.present? && to.length == 11
            sms_type, body  = view.render
            message = Ddt::ShortMessage.wrap_short_message_to_send(event.shop, to, sms_type, body)
            message.save!
          else
            Rails.logger.error "手机号码#{to}的格式非法，无法发送短信"
          end
        end
      end
    end
  end
end
