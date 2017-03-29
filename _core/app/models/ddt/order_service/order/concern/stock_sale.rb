module Ddt
  module OrderService
    module Order
      module Concern
        module StockSale
          extend ActiveSupport::Concern
          included do
          end
          def update_stock_quantity(line_items=nil)
            line_items ||= self.line_items.active
            ActiveRecord::Base.transaction do
              variant_stocks = {}
              line_items.each do |line_item|
                if line_item.itemable_type == "Ddt::Variant"
                  variant_stocks[line_item.itemable_id] ||= 0
                  variant_stocks[line_item.itemable_id] += line_item.active_quantity
                elsif line_item.itemable_type == "Ddt::ComboPackage"
                  combo = line_item.itemable.combo
                  Combo.update_counters(combo.id, stock_quantity: - line_item.active_quantity)
                  line_item.itemable.combo_package_items.each do |item|
                    variant_stocks[item.variant_id] ||= 0
                    variant_stocks[item.variant_id] += item.quantity * line_item.active_quantity
                  end
                else
                  line_item.update_stock_quantity
                end
              end
              variant_stocks = filter(variant_stocks)
              if variant_stocks.present?
                sql = []
                sql << "UPDATE `ddt_variants`"
                sql << "SET `ddt_variants`.`stock_quantity` = CASE `ddt_variants`.`id`"
                variant_stocks.each do |k, v|
                  sql << "WHEN #{k} THEN `ddt_variants`.`stock_quantity` - #{v}"
                end
                sql << "END"
                sql << "WHERE `ddt_variants`.`id` IN (#{variant_stocks.keys.join(',')});"
                ActiveRecord::Base.connection.execute(sql.join(" "))
                touch_product(variant_stocks.keys)
                estimate_clear_if_stock_quantity_is_zero(variant_stocks)
              end

            end
          end

          def filter(variant_stocks)
            return variant_stocks if variant_stocks.blank?
            variants = Ddt::Variant.where(id: variant_stocks.keys)
            branch_check_stock = variants[0].branch.check_stock?
            white_ids = variants.select{|v| v.estimate_clear_reciprocal? || branch_check_stock}.map(&:id)
            variant_stocks.slice!(*white_ids)
            variant_stocks
          end

          def update_sale_quantity(line_items=nil)
            line_items ||= self.line_items.active
            ActiveRecord::Base.transaction do
              variant_sales = {}
              line_items.each do |line_item|
                if line_item.itemable_type == "Ddt::Variant"
                  variant_sales[line_item.itemable_id] ||= 0
                  variant_sales[line_item.itemable_id] += line_item.active_quantity
                elsif line_item.itemable_type == "Ddt::ComboPackage"
                  combo = line_item.itemable.combo
                  Combo.update_counters(combo.id, sale_quantity: line_item.active_quantity)
                  line_item.itemable.combo_package_items.each do |item|
                    variant_sales[item.variant_id] ||= 0
                    variant_sales[item.variant_id] += item.quantity * line_item.active_quantity
                  end
                else
                  line_item.update_sale_quantity
                end
              end
              if variant_sales.present?
                sql = []
                sql << "UPDATE `ddt_variants`"
                sql << "SET `ddt_variants`.`sale_quantity` = CASE `ddt_variants`.`id`"
                variant_sales.each do |k, v|
                  sql << "WHEN #{k} THEN `ddt_variants`.`sale_quantity` + #{v}"
                end
                sql << "END"
                sql << "WHERE `ddt_variants`.`id` IN (#{variant_sales.keys.join(',')});"
                ActiveRecord::Base.connection.execute(sql.join(" "))
                touch_product(variant_sales.keys)
              end
            end
          end

          def rollback_stock_quantity(line_items=nil)
            line_items ||= self.line_items.active
            ActiveRecord::Base.transaction do
              variant_stocks = {}
              line_items.each do |line_item|
                if line_item.itemable_type == "Ddt::Variant"
                  variant_stocks[line_item.itemable_id] ||= 0
                  variant_stocks[line_item.itemable_id] += line_item.active_quantity
                elsif line_item.itemable_type == "Ddt::ComboPackage"
                  combo = line_item.itemable.combo
                  Combo.update_counters(combo.id, stock_quantity: line_item.active_quantity)
                  line_item.itemable.combo_package_items.each do |item|
                    variant_stocks[item.variant_id] ||= 0
                    variant_stocks[item.variant_id] += item.quantity * line_item.active_quantity
                  end
                else
                  line_item.rollback_stock_quantity
                end
              end
              if variant_stocks.present?
                remove_estimate_clear_if_stock_quantity_was_zero(variant_stocks)
                sql = []
                sql << "UPDATE `ddt_variants`"
                sql << "SET `ddt_variants`.`stock_quantity` = CASE `ddt_variants`.`id`"
                variant_stocks.each do |k, v|
                  sql << "WHEN #{k} THEN `ddt_variants`.`stock_quantity` + #{v}"
                end
                sql << "END"
                sql << "WHERE `ddt_variants`.`id` IN (#{variant_stocks.keys.join(',')});"
                ActiveRecord::Base.connection.execute(sql.join(" "))
              end
            end
          end

          def touch_product(variant_ids)
            return if variant_ids.blank?
            product_ids = Ddt::Variant.where(id: variant_ids).pluck(:product_id)
            Ddt::Product.where(id: product_ids).update_all(updated_at: Time.now)
          end

          private

          def estimate_clear_if_stock_quantity_is_zero(variant_stocks)
            return if variant_stocks.blank?
            Ddt::Variant.where(id: variant_stocks.keys, estimate_clear_reciprocal: true).each do |variant|
              if variant.stock_quantity == 0
                variant.add_estimate_clear(notify_self: true)
              end
            end
          end

          def remove_estimate_clear_if_stock_quantity_was_zero(variant_stocks)
            return if variant_stocks.blank?
            Ddt::Variant.where(id: variant_stocks.keys, estimate_clear: true).each do |variant|
              if variant.stock_quantity == 0
                variant.remove_estimate_clear(quantity: 0, notify_self: true)
                variant.update(estimate_clear_reciprocal: true)
              end
            end
          end

        end
      end
    end
  end
end
