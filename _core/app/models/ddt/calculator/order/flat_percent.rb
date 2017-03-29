# encoding:utf-8
# 统一折扣
module Ddt
  class Calculator
    module Order
      class FlatPercent < ::Ddt::Calculator
        preference :flat_percent, :decimal, default: 100

        validates :preferred_flat_percent, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 100}


        def compute(computable)
          (computable.computable_price * preferred_flat_percent / 100).round(2)
        end
      end
    end
  end
end