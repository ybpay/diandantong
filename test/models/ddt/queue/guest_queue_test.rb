require "test_helper"
module Ddt
  class GuestQueueTest < TestCase::Base
    let(:queue_setting) { create :queue_setting, branch: branch, shop: shop }
    let(:guest_queue) { queue_setting.new_guest_queue(base_user: user, guest_num: 1, phone: "123123123")}
    concerning :PreOrderItemables do
      def test_pre_order_itemables
        set_user_pre_order
        assert_equal guest_queue.pre_order_itemables.count, 1
      end

      def test_pre_order_detail_in_bill
        set_user_pre_order
        bill = guest_queue.pre_order_detail_in_bill
        assert bill.include?(variant.name)
      end

      private
      def set_user_pre_order
        cart = OrderService::Cart::EatInHall.new(branch: branch, user: user)
        cart.add(variant)
        user.set_pre_order_itemables(cart)
      end
    end
  end
end