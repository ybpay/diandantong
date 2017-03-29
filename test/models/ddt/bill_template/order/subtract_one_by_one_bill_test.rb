require "test_helper"
module Ddt
  module BillTemplate
    module Order
      class SubtractOneByOneBillTest < TestCase::Base
        let(:order){
          order = example_eat_in_hall_order
          subtractable = OrderService::Subtractable.new(order: order, line_item_id: order.line_items.first.id, quantity: 1)
          order.subtract(subtractable)
          order.reload
        }
        let(:log){ order.order_change_logs.subtract_itemable.first }
        let(:printer){ create(:normal_printer, branch: branch) }
        def test_render
          bill = BillTemplate::Order::SubtractOneByOneBill.new(order: order, printer: printer, order_change_log:log).render.first
          assert bill.include?(order.number)
          assert bill.include?(variant.name)
        end

        def test_preview
          bill = BillTemplate::Order::SubtractOneByOneBill.preview(branch)
          assert bill.include?("B12016020112000001")
          assert bill.include?("鱼香茄子")
        end
      end
    end
  end
end