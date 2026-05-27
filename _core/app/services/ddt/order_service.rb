# frozen_string_literal: true

module Ddt
  module OrderService
    class CreateOrder
      def initialize(shop:, branch:, user:, order_type:, items:, **options)
        @shop = shop
        @branch = branch
        @user = user
        @order_type = order_type
        @items = items
        @options = options
      end

      def call
        ApplicationRecord.transaction do
          order = build_order
          add_line_items(order)
          apply_promotions(order)
          calculate_totals(order)
          order.save!
          OrderCreatedEvent.call(order)
          order
        end
      end

      private

      attr_reader :shop, :branch, :user, :order_type, :items, :options

      def build_order
        order_class = order_class_for(order_type)
        order_class.new(
          shop: shop,
          branch: branch,
          user: user,
          state: :pending,
          **options
        )
      end

      def add_line_items(order)
        items.each do |item_params|
          line_item = Ddt::OrderService::LineItem.new(
            order: order,
            variant_id: item_params[:variant_id],
            quantity: item_params[:quantity] || 1,
            price: item_params[:price]
          )
          order.line_items << line_item
        end
      end

      def apply_promotions(order)
        Ddt::PromotionEngine::ApplyPromotions.call(order)
      end

      def calculate_totals(order)
        order.item_total = order.line_items.sum(&:total)
        order.adjustment_total = order.adjustments.sum(&:amount)
        order.total = order.item_total + order.adjustment_total
      end

      def order_class_for(type)
        case type.to_sym
        when :delivery    then Ddt::OrderService::Order::Delivery
        when :eat_in_hall then Ddt::OrderService::Order::EatInHall
        when :fastfood    then Ddt::OrderService::Order::Fastfood
        when :reservation then Ddt::OrderService::Order::Reservation
        when :groupon     then Ddt::OrderService::Order::Groupon
        when :recharge    then Ddt::OrderService::Order::Recharge
        when :payment     then Ddt::OrderService::Order::Payment
        else raise ArgumentError, "Unknown order type: #{type}"
        end
      end
    end

    class ConfirmOrder
      def initialize(order, confirmed_by:)
        @order = order
        @confirmed_by = confirmed_by
      end

      def call
        ApplicationRecord.transaction do
          @order.confirm!
          notify_kitchen(@order)
          notify_customer(@order)
          @order
        end
      end

      private

      def notify_kitchen(order)
        Ddt::PushService::KitchenNotify.call(order)
      end

      def notify_customer(order)
        Ddt::PushService::CustomerNotify.order_confirmed(order)
      end
    end

    class CancelOrder
      def initialize(order, cancelled_by:, reason: nil)
        @order = order
        @cancelled_by = cancelled_by
        @reason = reason
      end

      def call
        ApplicationRecord.transaction do
          @order.cancel!
          refund_payment(@order) if @order.paid?
          notify_customer(@order)
          @order
        end
      end

      private

      def refund_payment(order)
        Ddt::PaymentService::Refund.call(order.latest_payment)
      end

      def notify_customer(order)
        Ddt::PushService::CustomerNotify.order_cancelled(order)
      end
    end

    class CompleteOrder
      def initialize(order)
        @order = order
      end

      def call
        ApplicationRecord.transaction do
          @order.complete!
          update_statistics(@order)
          award_vip_points(@order)
          @order
        end
      end

      private

      def update_statistics(order)
        Ddt::StatisticService.record_order(order)
      end

      def award_vip_points(order)
        return unless order.user&.vip_info

        vip_info = order.user.vip_info
        points = (order.total * vip_info.vip_level.points_rate).floor
        vip_info.class.update_counters(vip_info.id, points: points)
      end
    end

    class OrderCreatedEvent
      def self.call(order)
        Ddt::OrderCreateWorker.perform_in(1.second, order.id)
      end
    end
  end
end
