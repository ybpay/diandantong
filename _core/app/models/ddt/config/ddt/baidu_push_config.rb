#encoding:utf-8
class Ddt::BaiduPushConfig < Settingslogic
  source "#{Rails.root}/config/baidu_push.yml"
  namespace Rails.env
end