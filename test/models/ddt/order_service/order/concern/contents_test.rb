module Ddt
  module OrderService
    module Order
      module Concern
        module ContentsTest
          extend ActiveSupport::Concern
          concerning :Append do
            def test_append_base
              if order.can_append_itemable?
                assert_change [
                  "order.line_items.count",
                  "order.order_change_logs.append_itemable.count",
                  "order.total"
                ] do
                  order.append(itemable.to_line_itemable)
                end
              end
            end
          end

          concerning :Subtract do
            def test_subtract_base
              if order.can_subtract_itemable?
                order.reload_line_item_trace_points
                assert_change [
                  "order.total",
                  "order.line_items.count",
                  "order.line_items.active.count",
                  "order.order_change_logs.subtract_itemable.count",
                  "order.line_item_trace_points.canceled.count",
                ] do
                  subtractable = OrderService::Subtractable.new(order: order, line_item_id: order.line_items.first.id, quantity: 1)
                  order.subtract(subtractable)
                end
              end
            end
          end
        end
      end
    end
  end
end
