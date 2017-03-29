require "test_helper"
module Ddt
  class Calculator
    module Order
      class FlatRateTest < TestCase::Base
        def test_compute
          calculator = create :calculator_order_flat_rate, preferred_amount: 90
          assert_equal 90, calculator.compute(nil)
        end
      end
    end
  end
end