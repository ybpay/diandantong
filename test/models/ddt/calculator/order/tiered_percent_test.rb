require "test_helper"
module Ddt
  class Calculator
    module Order
      class TieredPercentTest < TestCase::Base
        def test_compute_return_base_amount
          computable = mock(computable_price: 100)
          calculator = create :calculator_order_tiered_percent, preferred_base_percent: 90, preferred_tiers: {}
          assert_equal 90, calculator.compute(computable)
        end

        def test_compute_return_tiered_amount
          computable = mock(computable_price: 100)
          calculator = create :calculator_order_tiered_percent, preferred_base_percent: 90, preferred_tiers: {100 => 80}
          assert_equal 80, calculator.compute(computable)
        end
      end
    end
  end
end