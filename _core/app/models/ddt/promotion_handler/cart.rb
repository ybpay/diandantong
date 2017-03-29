module Ddt
  module PromotionHandler
    class Cart
      attr_accessor :cart
      def initialize(cart)
        @cart = cart
      end

      def activate
        cart.shop.order_promotions.active.active_in_branch(cart.branch).each do |promotion|
          promotion.activate(cart) if promotion.eligible?(cart)
        end
        cart.branch.order_promotions.active.each do |promotion|
          promotion.activate(cart) if promotion.eligible?(cart)
        end
        cart.branch.product_promotions.active.each do |promotion|
          promotion.activate(cart) if promotion.eligible?(cart)
        end
      end
    end
  end
end