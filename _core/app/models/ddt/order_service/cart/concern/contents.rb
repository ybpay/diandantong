module Ddt
  module OrderService
    module Cart
      module Concern
        module Contents
          extend ActiveSupport::Concern
          included do
          end

          def add(line_itemable, options={})
            merge = options.fetch(:merge, true)
            options.delete(:merge)
            line_itemable = OrderService::LineItemable.new(line_itemable, options) unless line_itemable.is_a?(OrderService::LineItemable)
            if line_itemable.can_add_to?(self)
              line_item = add_to_line_item(line_itemable, merge: merge)
              check_itemable_min_quantity_for_order(line_itemable.itemable) do |diff|
                line_item.quantity += diff
              end
              line_item
            end
          end

          def remove(line_itemable, options={})
            line_itemable = OrderService::LineItemable.new(line_itemable, options) unless line_itemable.is_a?(OrderService::LineItemable)
            line_item = remove_from_line_item(line_itemable)
            check_itemable_min_quantity_for_order(line_itemable.itemable) do |diff|
              self.line_items.of_itemable(line_itemable.itemable).each{|l| self.line_items.delete(l)}
            end
            line_item
          end

          def clear
            self.line_items = []
          end

          def update_line_items(line_itemables)
            self.line_items = line_itemables.select{|li| li.can_add_to?(self) }.map do |line_itemable|
              OrderService::LineItem.new(line_itemable.to_options.merge(cart: self))
            end
          end

          def update_form_contents(form_contentables)
            self.form_contents = form_contentables.map do |form_contentable|
              OrderService::FormContent.new(form_contentable.to_options.merge(cart: self))
            end
          end

          private
          def add_to_line_item(line_itemable, merge: false)
            line_item = self.line_items.of_line_itemable(line_itemable).first if merge
            if line_item.present?
              line_item.quantity += line_itemable.quantity
            else
              line_item = OrderService::LineItem.new(line_itemable.to_options.merge(cart: self))
              self.line_items.push(line_item)
            end
            line_item
          end

          def remove_from_line_item(line_itemable)
            line_item = self.line_items.of_line_itemable(line_itemable).first
            line_item = self.line_items.of_itemable(line_itemable.itemable).first if line_item.blank?
            if line_item.present?
              line_item.quantity -= line_itemable.quantity.to_i
              self.line_items.delete(line_item) if line_item.quantity <= 0
              line_item
            end
          end

          def check_itemable_min_quantity_for_order(itemable)
            min_quantity_for_order = itemable.min_quantity_for_order
            quantity_in_order = self.line_items.of_itemable(itemable).map(&:quantity).sum
            if quantity_in_order < min_quantity_for_order
              yield(min_quantity_for_order - quantity_in_order) if block_given?
            end
          end
        end
      end
    end
  end
end
