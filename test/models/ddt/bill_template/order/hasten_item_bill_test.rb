require "test_helper"
module Ddt
  module BillTemplate
    module Order
      class HastenItemBillTest < TestCase::Base
        let(:order){ example_eat_in_hall_order }
        let(:printer){ create(:normal_printer, branch: branch) }
        let(:event){ order.hasten(track_from: :FromWebpos, line_item_id: order.line_items.first.id)}
        def test_render
          bill = BillTemplate::Order::HastenItemBill.new(order: order, printer: printer, event: event).render
          assert bill.include?(order.number)
          assert bill.include?(order.line_items.first.name)
        end

        def test_preview
          bill = BillTemplate::Order::HastenItemBill.preview(branch)
          assert bill.include?("B12016020112000001")
          assert bill.include?("宫爆鸡丁[加辣]")
        end
      end
    end
  end
end
