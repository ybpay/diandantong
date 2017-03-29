require "test_helper"
module Ddt
  class UserTest < TestCase::Base
    let(:cart){ OrderService::Cart::EatInHall.new(branch: branch, user: user) }
    concerning :PreOrderItemable do
      def test_set_pre_order_itemables
        cart.add(variant)
        assert_change "user.order_itemables.count" do
          user.set_pre_order_itemables(cart)
        end
        assert_equal user.pre_order_itemables(branch).first.itemable, variant
      end

      def test_clear_pre_order_itemables
        cart.add(variant)
        user.set_pre_order_itemables(cart)
        user.clear_pre_order_itemables(branch)
        assert_equal user.pre_order_itemables(branch).count, 0
      end
    end
  end
end