require "test_helper"
module Ddt
  module BillTemplate
    module Queue
      class PreOrderBillTest < TestCase::Base
        let(:queue_setting) { create :queue_setting, branch: branch, shop: shop }
        let(:guest_queue) {
          guest = queue_setting.new_guest_queue(base_user: user, guest_num: 1, phone: "123123123")
          cart = OrderService::Cart::EatInHall.new(table: table, branch: branch, track_from: :FromWebpos)
          cart.add(variant)
          user.set_pre_order_itemables(cart)
          guest
        }
        let(:printer){ create(:normal_printer, branch: branch) }
        def test_render
          bill = BillTemplate::Queue::PreOrderBill.new(guest_queue: guest_queue, printer: printer).render
          assert bill.include?(guest_queue.guest_no)
          assert bill.include?(variant.name)
        end

        def test_preview
          bill = BillTemplate::Queue::PreOrderBill.preview(branch)
          assert bill.include?("A003")
          assert bill.include?("宫爆鸡丁")
        end
      end
    end
  end
end