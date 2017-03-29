#encoding: utf-8
class Ddt::WechatpaySl < Settingslogic
  source "#{Rails.root}/config/wechatpay_sl.yml"
  namespace Rails.env
end
