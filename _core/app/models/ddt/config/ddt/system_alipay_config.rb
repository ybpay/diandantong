# encoding: utf-8
class Ddt::SystemAlipayConfig < Settingslogic
  source "#{Rails.root}/config/system_alipay.yml"
  namespace Rails.env
end
