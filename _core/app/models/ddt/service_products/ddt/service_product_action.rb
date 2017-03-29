# encoding: utf-8
module Ddt
  class ServiceProductAction
    attr_accessor :shop, :product_type, :quantity

    def initialize(shop, service_product)
      @shop = shop
      @product_type = service_product.product_type.to_sym
      @quantity = service_product.quantity
    end

    def perform
      case product_type
      when :sms_recharge
        shop.recharge_short_messages(quantity)
      when :printer_code
        # TODO
      end
    end

  end
end
