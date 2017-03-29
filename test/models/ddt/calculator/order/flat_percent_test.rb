require "test_helper"
module Ddt
  class Calculator
    module Order
      class FlatPercentTest < TestCase::Base
        def test_compute
          computable = mock(computable_price: 100)
          calculator = create :calculator_order_flat_percent, preferred_flat_percent: 90
          assert_equal 90, calculator.compute(computable)
        end
      end
    end
  end
end