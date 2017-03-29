require "test_helper"
module Ddt
  module BillTemplate
    module Shift
      class BillTest < TestCase::Base
        let(:shift) {
          shift = create(:shift, branch_id: branch.id, shop_id: shop.id)
          order = example_eat_in_hall_order
          pay_itemable = OrderService::PayItemable.new(pay_method_name_sym: :pay_on_face, amount: order.total, shop: shop, branch: branch)
          pay_item = order.load_pay_item(pay_itemable)
          order.change_pay_item_to_paid(pay_item)
          pay_item.update(paid_at: 30.minute.ago)
          order.save
          shift.close
          shift
        }
        let(:printer){ create(:normal_printer, branch: branch) }
        def test_render
          bill = BillTemplate::Shift::Bill.new(shift, printer).render
          assert bill.include?("现金")
        end

        def test_preview
          bill = BillTemplate::Shift::Bill.preview(branch)
          assert bill.include?("T001")
        end
      end
    end
  end
end