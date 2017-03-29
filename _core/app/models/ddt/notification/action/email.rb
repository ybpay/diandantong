module Ddt
  class Notification
    module Action
      class Email < Ddt::NotificationAction
        def perform
          view = Ddt::Notification::View::Email.new(event, target)
          if target.is_a?(Ddt::BaseUser)
            to = target.try(:email)
          elsif target.is_a?(Ddt::Account) && target.receive_email?
            to = target.try(:notification_email)
          end
          if to.present?
            subject, body = view.render
            NotificationMailer.notify(to, subject, body, self.shop).deliver
          end
        end
      end
    end
  end
end