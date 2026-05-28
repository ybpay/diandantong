module Ddt
  module OrderService
    module Collection
      class LineItems < Collection::Base
        scope :of_line_itemable, ->(line_itemable){ select{|line_item| line_item.same_line_itemable?(line_itemable)} }
        scope :of_itemable, ->(itemable){ select{|line_item| line_item.same_itemable?(itemable)} }
        scope :active, ->{ select(&:active?) }
        scope :inactive, -> {select{|l| !l.active?}}
        scope :subtract, -> { select(&:is_subtract?)}
        scope :moved, -> { select(&:is_moved?)}
        scope :from_move, -> { select(&:is_from_move?)}
        scope :enable_discount, -> {select(&:enable_discount?)}
        scope :can_discount, -> { select(&:can_discount?)}
        scope :by_log, ->(log){ select{|line_item| line_item.order_change_log_id == log.try(:id)} }
        scope :sort_desc, -> {sort{|a, b| b.active_quantity * b.price - a.active_quantity * a.price}}

        def include_itemables(variant: [], variant_package: [], combo_package: [])
          variant_ids = active.select(&:is_variant?).map(&:itemable_id).uniq
          variant_package_ids = active.select(&:is_variant_package?).map(&:itemable_id).uniq
          combo_package_ids = active.select(&:is_combo_package?).map(&:itemable_id).uniq
          variants = Variant.with_discarded.includes(variant).find(variant_ids)
          variant_packages = VariantPackage.includes(variant_package).find(variant_package_ids)
          combo_packages = ComboPackage.includes(combo_package).find(combo_package_ids)
          active.map do |item|
            if item.is_variant?
              item.itemable = variants.detect{|v| v.id == item.itemable_id }
            elsif item.is_variant_package?
              item.itemable = variant_packages.detect{|v| v.id == item.itemable_id }
            elsif item.is_combo_package?
              item.itemable = combo_packages.detect{|v| v.id == item.itemable_id }
            end
            item
          end
        end

        def item_count
          active.map(&:active_quantity).sum
        end

        def item_total
          active.map(&:total).sum
        end

        def item_total_for_discount
          active.select(&:can_discount?).map(&:total).sum
        end

        def combos
          active.select(&:is_combo_package?).map(&:itemable).map(&:combo)
        end

        def variants
          active.select(&:is_variant?).map(&:itemable)
        end

        def variant_packages
          active.select(&:is_variant_package?).map(&:itemable)
        end

        def products
          variants.map(&:product)
        end

        def group_by_itemable
          itemables = self.map(&:itemable).uniq
          self.group_by{|line_item| itemables.index(line_item.itemable)}.map do |index, line_items|
            {
              itemable: itemables[index],
              line_items: self.class.new(line_items)
            }
          end
        end

        def to_line_itemable_options
          self.map(&:to_line_itemable_options)
        end

        def count_stock
          Collection::StockItems.init_from_line_itemables(self.map(&:line_itemable)).count_stock
        end

        def calculate_item_adjustments(total:, is_apportion: false, &calculator)
          sorted_items = self.sort_desc
          item_amounts = sorted_items.map do |line_item|
            calculator.call(line_item.subtotal)
          end
          if item_amounts.present?
            diff = total - item_amounts.sum
            item_amounts[0] += diff
          end
          sorted_items.map.with_index{|line_item, index| line_item.get_item_adjustment(item_amounts[index], is_apportion: is_apportion)}
        end

        def find_by_item_adjustment(item_adjustment)
          if item_adjustment.line_item_id
            find(item_adjustment.line_item_id)
          else
            to_a[item_adjustment.line_item_index]
          end
        end

      end
    end
  end
end
