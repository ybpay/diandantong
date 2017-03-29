# encoding:utf-8
# 统一减免
module Ddt
  class Calculator
    module Order
      class FlatReduce < ::Ddt::Calculator
        preference :flat_reduce_amount, :decimal, default: 0

        def compute(computable)
          computable.computable_price - self.preferred_flat_reduce_amount
        end
      end
    end
  end
end