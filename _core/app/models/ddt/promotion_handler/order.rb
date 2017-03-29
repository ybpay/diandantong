module Ddt
  module PromotionHandler
    class Order
      attr_accessor :order
      def initialize(order)
        @order = order
      end

      def activate
        disabled_ids = order.disabled_promotion_ids
        order.shop.order_promotions.active.active_in_branch(order.branch).each do |promotion|
          promotion.activate(order) if !disabled_ids.include?(promotion.id) && promotion.eligible?(order)
        end
        order.branch.order_promotions.active.each do |promotion|
          promotion.activate(order) if !disabled_ids.include?(promotion.id) && promotion.eligible?(order)
        end
        order.branch.product_promotions.active.each do |promotion|
          promotion.activate(order) if !disabled_ids.include?(promotion.id) && promotion.eligible?(order)
        end
      end
    end
  end
end