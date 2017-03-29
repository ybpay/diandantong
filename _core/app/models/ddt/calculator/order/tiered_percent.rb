# encoding:utf-8
# 阶梯折扣
module Ddt
  class Calculator
    module Order
      class TieredPercent < Ddt::Calculator
        preference :base_percent, :decimal, default: 0
        preference :tiers, :digest, default: {}

        before_validation do
          # Convert tier values to decimals. Strings don't do us much good.
          if preferred_tiers.is_a?(Hash)
            self.preferred_tiers = Hash[*preferred_tiers.flatten.map(&:to_f)]
          end
        end

        validates :preferred_base_percent, numericality: {
          greater_than_or_equal_to: 0,
          less_than_or_equal_to: 100
        }
        validate :preferred_tiers_content

        def compute(computable)
          computable_price = computable.computable_price
          base, percent = preferred_tiers.sort.reverse.detect{ |b,_| computable_price >= b }
          (computable_price * (percent || preferred_base_percent) / 100).round(2)
        end

        private
        def preferred_tiers_content
          if preferred_tiers.is_a? Hash
            unless preferred_tiers.keys.all?{ |k| k.is_a?(Numeric) && k > 0 }
              errors.add(:base, :keys_should_be_positive_number)
            end
            unless preferred_tiers.values.all?{ |k| k.is_a?(Numeric) && k >= 0 && k <= 100 }
              errors.add(:base, :values_should_be_percent)
            end
          else
            errors.add(:preferred_tiers, :should_be_hash)
          end
        end
      end
    end
  end
end