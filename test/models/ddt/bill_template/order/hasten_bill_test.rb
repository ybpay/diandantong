require "test_helper"
module Ddt
  module BillTemplate
    module Order
      class HastenBillTest < TestCase::Base
        let(:order){ example_eat_in_hall_order }
        let(:printer){ create(:normal_printer, branch: branch) }
        let(:event){ order.hasten(track_from: :FromWebpos)}
        def test_render
          bill = BillTemplate::Order::HastenBill.new(order: order, printer: printer, event: event).render
          assert bill.include?(order.number)
        end

        def test_preview
          bill = BillTemplate::Order::HastenBill.preview(branch)
          assert bill.include?("B12016020112000001")
        end
      end
    end
  end
end
