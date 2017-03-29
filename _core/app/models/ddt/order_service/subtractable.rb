module Ddt
  module OrderService
    class Subtractable
      attr_accessor :order, :line_item_id, :quantity, :line_item, :reason
      def initialize(params={})
        @order = params.fetch(:order)
        @line_item_id = params.fetch(:line_item_id)
        @quantity = params.fetch(:quantity).to_i
        @reason = params.fetch(:reason, "")
        @line_item = @order.line_items.active.find(@line_item_id)
      end

      def valid?
        line_item.present? && line_item.active_quantity >= quantity
      end

      def self.init_list(subtractable_attribute_array=[], order:)
        attr_array = subtractable_attribute_array.map(&:symbolize_keys)
        attr_array.map{ |p| self.new(p.merge(order: order)) }.select(&:valid?)
      end

      def to_options
        options = {
          order: order,
          is_subtract: true,
          source_line_item_id: line_item.id,
          itemable: line_item.itemable,
          quantity: quantity,
          subtract_reason: reason
        }
        [:product_name, :itemable_name, :category_names, :unit_name, :vip_price, :original_price, :price, :enable_discount, :gift, :note, :gift_reason].each do |method_name|
          options[method_name] = line_item.send(method_name)
        end
        options
      end
    end
  end
end