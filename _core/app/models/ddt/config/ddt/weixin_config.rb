#encoding: utf-8
class Ddt::WeixinConfig < Settingslogic
  source "#{Rails.root}/config/weixin_config.yml"
  namespace Rails.env
end