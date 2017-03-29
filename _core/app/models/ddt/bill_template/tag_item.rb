module Ddt
  module BillTemplate
    class TagItem
      attr_accessor :source_item
      attr_accessor :item_name, :item_quantity, :item_price, :item_subtotal, :item_note, :item_product_name, :item_subtotal_after_discount
      delegate :itemable, :line_item_id, :is_combo_package?,
               to: :source_item, allow_nil: true
      def initialize(source_item)
        @source_item = source_item
        @item_name      = source_item.respond_to?(:item_name)      ? source_item.item_name      : source_item.name
        @item_quantity  = source_item.respond_to?(:item_quantity)  ? source_item.item_quantity  : source_item.active_quantity
        @item_price     = source_item.respond_to?(:item_price)     ? source_item.item_price     : source_item.price
        @item_subtotal  = source_item.respond_to?(:item_subtotal)  ? source_item.item_subtotal  : source_item.subtotal
        @item_note      = source_item.respond_to?(:item_note)      ? source_item.item_note      : source_item.note
        @item_subtotal_after_discount  = source_item.respond_to?(:item_subtotal_after_discount)  ? source_item.item_subtotal_after_discount  : source_item.try(:subtotal_after_discount)
        @item_product_name = source_item.try(:item_product_name) || source_item.try(:product_name)
      end

      def group_key
        "#{source_item.itemable_type}#{source_item.itemable_id}"
      end

      def self.merge(items)
        if items.present?
          items_after_merge = items.group_by(&:group_key).map do |key, group_items|
            if group_items.count > 1
              merged_item = group_items.first
              group_items.each_with_index do |item, index|
                if index > 0
                  merged_item.item_quantity += item.item_quantity
                  merged_item.item_subtotal += item.item_subtotal
                  merged_item.item_subtotal_after_discount += item.item_subtotal_after_discount
                  merged_item.item_note = [merged_item.item_note, item.item_note].compact.join(" ")
                end
              end
              merged_item
            elsif group_items.count == 1
              group_items.first
            end
          end
        else
          []
        end
      end
    end
  end
end