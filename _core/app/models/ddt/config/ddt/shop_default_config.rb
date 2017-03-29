#encoding: utf-8
class Ddt::ShopDefaultConfig < Settingslogic
  source "#{Rails.root}/config/shop_default_config.yml"
  namespace Rails.env
end