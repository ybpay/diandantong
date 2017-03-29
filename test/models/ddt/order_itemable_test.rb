require "test_helper"
module Ddt
  class OrderItemableTest < TestCase::Base
    let(:order_itemable_for_merge_order){
      OrderItemable.create(
        table: table,
        user: user,
        store_type: :for_merge_order,
        itemable: variant,
        quantity: 1
      )
    }
    let(:order_itemable){ order_itemable_for_merge_order }

    def test_plus
      order_itemable.plus
      assert_equal 2, order_itemable.quantity
    end

    def test_minus
      order_itemable.plus
      order_itemable.minus
      assert_equal 1, order_itemable.quantity
    end

    def test_minus_destroy
      order_itemable.minus
      assert_equal 0, order_itemable.quantity
      assert order_itemable.destroyed?
    end
  end
end