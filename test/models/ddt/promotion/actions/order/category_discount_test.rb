require "test_helper"
module Ddt
  class Promotion
    module Actions
      module Order
        class CategoryDiscountTest < TestCase::Base
          def test_compute_amount_of_adjustment
            cart = OrderService::Cart::Fastfood.new(branch: branch, track_from: :FromWebpos)
            cart.add(variant)
            order = cart.place
            action = Promotion::Actions::Order::CategoryDiscount.new(preferred_discount: 80)
            action.stubs(:categories).returns(variant.product.categories)
            assert_equal (-variant.price * 0.2), action.compute_amount_of_adjustment(order)
          end
        end
      end
    end
  end
end