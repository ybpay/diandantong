require "test_helper"
module Ddt
  class Promotion
    module Actions
      module Order
        class ItemSecondHalfOffTest < TestCase::Base
          def test_compute_amount_of_adjustment
            cart = OrderService::Cart::Fastfood.new(branch: branch, track_from: :FromWebpos)
            cart.add(variant, quantity: 2)
            order = cart.place
            action = Promotion::Actions::Order::ItemSecondHalfOff.new
            action.stubs(:variant_ids).returns([variant.id])
            assert_equal (-variant.price/2), action.compute_amount_of_adjustment(order)
          end
        end
      end
    end
  end
end