# encoding:utf-8
# 统一价格
module Ddt
  class Calculator
    module Order
      class FlatRate < ::Ddt::Calculator
        preference :amount, :decimal, default: 0

        def compute(computable=nil)
          self.preferred_amount
        end
      end
    end
  end
end