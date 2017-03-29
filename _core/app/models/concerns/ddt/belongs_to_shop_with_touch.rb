module Ddt
  module BelongsToShopWithTouch
    extend ActiveSupport::Concern
    included do
      belongs_to :shop, class_name: 'Ddt::Shop', touch: true

      def shop
        TCC.fetch("shop.#{self.shop_id}") {super}
      end

      validates :shop_id, presence: true

    end

    module ClassMethods
    end
  end
end
