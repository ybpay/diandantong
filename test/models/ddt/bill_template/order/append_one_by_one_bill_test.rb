require "test_helper"
module Ddt
  module BillTemplate
    module Order
      class AppendOneByOneBillTest < TestCase::Base
        let(:order){
          order = example_eat_in_hall_order
          order.append(variant.to_line_itemable)
          order.reload
        }
        let(:log){ order.order_change_logs.append_itemable.first }
        let(:printer){ create(:normal_printer, branch: branch) }
        def test_render
          bill = BillTemplate::Order::AppendOneByOneBill.new(order: order, printer: printer, order_change_log: log).render.first
          assert bill.include?(order.number)
          assert bill.include?(variant.name)
        end

        def test_preview
          bill = BillTemplate::Order::AppendOneByOneBill.preview(branch)
          assert bill.include?("B12016020112000001")
          assert bill.include?("鱼香茄子")
        end
      end
    end
  end
end