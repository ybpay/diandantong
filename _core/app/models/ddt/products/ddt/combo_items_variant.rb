module Ddt
  class ComboItemsVariant < Ddt::Base
    include Ddt::HasVipPrice
    attr_accessor :price_strategy
    belongs_to :combo_item, touch: true
    belongs_to :variant
    replicated_model

    # validations
    validates_presence_of :variant_id
    validates_presence_of :price, :vip_price, if: :is_dynamic_price?
    validate :vip_price_lteq_price, if: :is_dynamic_price?

    # callbacks
    before_save :set_prices

    private

      def is_dynamic_price?
        price_strategy == 'dynamic_price'
      end

      def set_prices
        if variant.present?
          self.original_price =  [variant.original_price, self.price].max
        end
      end
  end
end
