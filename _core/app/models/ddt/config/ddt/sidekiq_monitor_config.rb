#encoding:utf-8
class Ddt::SidekiqMonitorConfig < Settingslogic
  source "#{Rails.root}/config/sidekiq_monitor_config.yml"
  namespace Rails.env
end