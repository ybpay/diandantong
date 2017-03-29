module Ddt
  module OrderService
    module Collection
      class StockItems
        attr_accessor :items
        include Enumerable

        def initialize(array=[])
          @items = array
        end

        delegate :each, :size, :first, to: :items

        def self.init_from_line_itemables(line_itemables)
          stockables = line_itemables.map do |line_itemable|
            line_itemable.itemable.to_stockables * line_itemable.quantity
          end.flatten
          hash = stockables.group_by{|i| "#{i.itemable_type}#{i.itemable_id}"}
          self.new(hash.map{|k, v| StockItem.new(v[0], v.size)})
        end

        def count_stock
          result = {enough: true, msgs: []}
          return result if size == 0
          branch_check_stock = first.stockable.branch.check_stock?
          each do |stock_item|

            if stock_item.ban?
              result[:enough] = false
              result[:msgs] << "#{stock_item.name} 已经卖光了"
              next
            end

            if stock_item.check? || branch_check_stock
              if !stock_item.enough?
                result[:enough] = false
                result[:msgs] << "#{stock_item.name}库存不足, 剩余#{stock_item.stockable.stock_quantity}"
              end
            end
          end
          result
        end

        class StockItem
          attr_accessor :stockable, :quantity
          def initialize(stockable, quantity)
            @stockable = stockable
            @quantity = quantity
          end

          def name
            stockable.name
          end

          def ban?
            stockable.estimate_clear? rescue false
          end

          def check?
            (stockable.estimate_clear_reciprocal? rescue false)
          end

          def enough?
            stockable.stock_enough?(quantity)
          end
        end

      end
    end
  end
end
