# encoding:utf-8
# 阶梯价格
module Ddt
  class Calculator
    module Order
      class TieredFlatRate < Ddt::Calculator
        preference :base_amount, :decimal, default: 0
        preference :tiers, :digest, default: {}

        before_validation do
          # Convert tier values to decimals. Strings don't do us much good.
          if preferred_tiers.is_a?(Hash)
            self.preferred_tiers = Hash[*preferred_tiers.flatten.map(&:to_f)]
          end
        end

        validate :preferred_tiers_content

        def compute(computable)
          computable_price = computable.computable_price
          base, amount = preferred_tiers.sort.reverse.detect{ |b,_| computable_price >= b }
          amount || preferred_base_amount
        end

        private
        def preferred_tiers_content
          if preferred_tiers.is_a? Hash
            unless preferred_tiers.keys.all?{ |k| k.is_a?(Numeric) && k > 0 }
              errors.add(:base, :keys_should_be_positive_number)
            end
          else
            errors.add(:preferred_tiers, :should_be_hash)
          end
        end
      end
    end
  end
end