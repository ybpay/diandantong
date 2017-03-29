module Ddt
  module HasVipPrice
    extend ActiveSupport::Concern

    def vip_price_lteq_price
      if price.is_a?(Numeric) && vip_price.is_a?(Numeric)
        self.errors[:vip_price] << I18n.t('vip price must less or equal than price') if vip_price > price
      end
    end

  end
end
