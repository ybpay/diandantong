module Ddt
  module OrderService
    module Order
      module Concern
        module Contents
          extend ActiveSupport::Concern
          included do
          end

          def append(line_itemables, note="")
            line_itemables = [line_itemables] if line_itemables.is_a?(OrderService::LineItemable)
            if can_append_itemable? && line_itemables.count > 0
              line_itemables = line_itemables.select{|li| li.can_add_to?(self)}
              check_stock_result = Collection::StockItems.init_from_line_itemables(line_itemables).count_stock
              if !check_stock_result[:enough]
                self.errors[:base] << " #{check_stock_result[:msgs].join(", ")}"
                false
              else
                transaction do
                  new_line_items = line_itemables.map do |line_itemable|
                    add(line_itemable)
                  end
                  update_stock_quantity(new_line_items)
                  add_change_log(:append_itemable, description: note)
                  update_total_and_save
                end
                after_append
                send_append_notification
                true
              end
            end
          end
          alias_method :append_itemable, :append

          def subtract(subtractables)
            subtractables = [subtractables] if subtractables.is_a?(OrderService::Subtractable)
            if can_subtract_itemable? && subtractables.count > 0
              transaction do
                subtract_line_items = subtractables.map do |subtractable|
                  subtractable.line_item.subtract_quantity += subtractable.quantity
                  line_item = OrderService::LineItem.new(subtractable.to_options)
                  self.line_items.push(line_item)
                  line_item
                end
                rollback_stock_quantity(subtract_line_items) if branch.check_stock?
                add_change_log(:subtract_itemable)
                cancel_line_item_trace_points(subtractables)
                update_total_and_save
              end
              after_subtract
              send_subtract_notification
            end
          end
          alias_method :subtract_itemable, :subtract
          alias_method :delete_itemable, :subtract

          def active_line_items
            self.line_items.active
          end

          def can_append_itemable?(need_errors: false)
            false
          end

          def can_subtract_itemable?(need_errors: false)
            false
          end
          alias_method :can_delete_itemable?, :can_subtract_itemable?

          private
          def add(line_itemable)
            line_item = OrderService::LineItem.new(line_itemable.to_options.merge(order: self, is_append: true))
            self.line_items.push(line_item)
            check_itemable_min_quantity_for_order(line_itemable.itemable) do |diff|
              line_item.quantity += diff
            end
            line_item
          end

          def check_itemable_min_quantity_for_order(itemable)
            min_quantity_for_order = itemable.min_quantity_for_order
            quantity_in_order = self.line_items.of_itemable(itemable).map(&:quantity).sum
            if quantity_in_order < min_quantity_for_order
              yield(min_quantity_for_order - quantity_in_order) if block_given?
            end
          end

          def send_append_notification
            order_change_log = self.order_change_logs.append_itemable.last
            Notification::Event::OrderChange::AppendItemable.create_and_send_notification(order_change_log: order_change_log, is_local_printed: is_local_printed)
          end

          def after_append
          end

          def send_subtract_notification
            order_change_log = self.order_change_logs.subtract_itemable.last
            Notification::Event::OrderChange::DeleteItemable.create_and_send_notification(order_change_log: order_change_log)
          end

          def after_subtract
          end

          def cancel_line_item_trace_points(subtractables)
            reload_line_item_trace_points if line_item_trace_points.blank?
            subtractables.each do |subtractable|
              line_item = subtractable.line_item
              itemable = subtractable.line_item.itemable
              quantity = subtractable.quantity
              mark = ->(itemable, quantity){
                line_item_trace_points.pending.by_line_item(line_item).by_itemable(itemable).first(quantity).each do |line_item_trace_point|
                  line_item_trace_point.cancel
                end
              }
              if line_item.is_variant? || line_item.is_variant_package?
                mark.call(itemable, quantity)
              elsif line_item.is_combo_package?
                itemable.each_item do |variant, variant_quantity|
                  mark.call(variant, quantity * variant_quantity)
                end
              end
            end
          end

        end
      end
    end
  end
end
