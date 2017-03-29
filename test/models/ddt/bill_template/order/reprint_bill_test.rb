require "test_helper"
module Ddt
  module BillTemplate
    module Order
      class ReprintBillTest < TestCase::Base
        let(:order){ example_eat_in_hall_order }
        let(:printer){ create(:normal_printer, branch: branch) }
        let(:event){
          printer = create(:normal_printer, branch: branch)
          event = order.reprint([printer.id], "补打备注")
        }
        def test_render
          bill = BillTemplate::Order::ReprintBill.new(order: order, printer: printer, event: event).render
          assert bill.include?(order.number)
          assert bill.include?("补打")
        end

        def test_preview
          bill = BillTemplate::Order::ReprintBill.preview(branch)
          assert bill.include?("B12016020112000001")
          assert bill.include?("补打")
        end
      end
    end
  end
end