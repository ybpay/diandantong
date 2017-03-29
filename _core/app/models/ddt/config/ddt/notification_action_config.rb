#encoding:utf-8
class Ddt::NotificationActionConfig < Settingslogic
  source "#{Rails.root}/config/notification_action_config.yml"
  namespace Rails.env
end