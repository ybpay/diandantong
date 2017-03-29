require "test_helper"
module Ddt
  class Promotion
    module Actions
      module Order
        class ItemReduceTest < TestCase::Base
          def test_compute_amount_of_adjustment
            cart = OrderService::Cart::Fastfood.new(branch: branch, track_from: :FromWebpos)
            cart.add(variant)
            order = cart.place
            action = Promotion::Actions::Order::ItemReduce.new(preferred_amount: 10)
            action.stubs(:variant_ids).returns([variant.id])
            assert_equal -10, action.compute_amount_of_adjustment(order)
          end
        end
      end
    end
  end
end