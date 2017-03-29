require "test_helper"
module Ddt
  module BillTemplate
    module Order
      class ProductBillTest < TestCase::Base
        let(:order){ example_eat_in_hall_order }
        let(:printer){ create(:normal_printer, branch: branch) }
        def test_render
          bill = BillTemplate::Order::ProductBill.new(order: order, printer: printer).render
          assert bill.include?(order.number)
          assert bill.include?(order.line_items.first.name)
        end

        def test_preview
          bill = BillTemplate::Order::ProductBill.preview(branch)
          assert bill.include?("B12016020112000001")
          assert bill.include?("宫爆鸡丁")
        end
      end
    end
  end
end