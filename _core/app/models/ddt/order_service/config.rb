#encoding:utf-8
module Ddt
  module OrderService
    class Config < Settingslogic
      source "#{Rails.root}/config/order_service_config.yml"
      namespace Rails.env
    end
  end
end