require "test_helper"
module Ddt
  class Calculator
    module Order
      class FlatReduceTest < TestCase::Base
        def test_compute
          computable = mock(computable_price: 100)
          calculator = create :calculator_order_flat_reduce, preferred_flat_reduce_amount: 10
          assert_equal 90, calculator.compute(computable)
        end
      end
    end
  end
end