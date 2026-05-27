# frozen_string_literal: true

module Ddt
  module PromotionEngine
    class ApplyPromotions
      def self.call(order)
        new(order).call
      end

      def initialize(order)
        @order = order
        @shop = order.shop
        @branch = order.branch
      end

      def call
        eligible_promotions.each do |promotion|
          if rules_satisfied?(promotion)
            apply_actions(promotion)
          end
        end
      end

      private

      attr_reader :order, :shop, :branch

      def eligible_promotions
        shop_promotions = shop.promotions_including_branch.active
        branch_promotions = branch&.promotions&.active || []
        (shop_promotions + branch_promotions).uniq
      end

      def rules_satisfied?(promotion)
        rules = fetch_rules(promotion)
        rules.all? { |rule| rule.satisfied?(order) }
      end

      def apply_actions(promotion)
        actions = fetch_actions(promotion)
        actions.each { |action| action.apply(order, promotion) }
      end

      def fetch_rules(promotion)
        config = promotion.for_branch? ? branch_config : shop_config
        config.rules.select { |r| promotion.rules.include?(r.class.name) }
      end

      def fetch_actions(promotion)
        config = promotion.for_branch? ? branch_config : shop_config
        config.actions.select { |a| promotion.actions.include?(a.class.name) }
      end

      def shop_config
        Rails.configuration.ddt.shop.order_promotions
      end

      def branch_config
        Rails.configuration.ddt.branch.order_promotions
      end
    end
  end
end
