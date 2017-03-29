require "test_helper"
module Ddt
  module BillTemplate
    module Shifts
      class ByTimeTest < TestCase::Base
        let(:shift) {
          shift = create(:shift, branch_id: branch.id, shop_id: shop.id)
          order = example_eat_in_hall_order
          order.operator = worker
          pay_itemable = OrderService::PayItemable.new(pay_method_name_sym: :pay_on_face, amount: order.total, shop: shop, branch: branch)
          pay_item = order.load_pay_item(pay_itemable)
          order.change_pay_item_to_paid(pay_item)
          pay_item.update(paid_at: 30.minute.ago)
          order.save
          shift.close
          shift
        }
        let(:printer){ create(:normal_printer, branch: branch) }
        let(:shift_list){
          shift
          Bill::Branch::ShiftList.new(branch, operator: worker, search_by: :by_time, date: Date.today.strftime("%F"), start_at: "09:00", end_at: "19:00")
        }
        def test_render
          bill = BillTemplate::Shifts::ByTime.new(shift_list, printer).render
          assert bill.include?("分时清单")
          assert bill.include?("消费人数:1")
          assert bill.include?("现金             10.0")
        end

        def test_preview
          bill = BillTemplate::Shifts::ByTime.preview(branch)
          assert bill.include?("分时清单")
          assert bill.include?("消费人数:1")
          assert bill.include?("会员卡支付(实收) 50")
        end
      end
    end
  end
end
