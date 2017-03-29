module Ddt
  class AppNotificationCache < Ddt::DdtEx
    replicated_model

    belongs_to :notification, :class_name => 'Ddt::Notification'
    belongs_to :notification_event, :class_name => 'Ddt::NotificationEvent'
    belongs_to :notification_action, :class_name => 'Ddt::NotificationAction'
    belongs_to :account, :class_name => 'Ddt::Account'

    def message
      message = read_attribute(:message)
      unless message.present?
        # view = Ddt::Notification::View::App.new(notification_action.id, notification_event, account)
        # message = view.render
        # self.update(message: message.to_json)
        {}
      else
        message = JSON.parse(message)
      end
      message.symbolize_keys
    end

  end
end
