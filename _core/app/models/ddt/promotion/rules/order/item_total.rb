# encoding:utf-8
module Ddt
  class Promotion
    module Rules
      module Order
        class ItemTotal < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          preference :amount_min   , :decimal , default: 100.00
          preference :operator_min , :string  , default: :>
          preference :amount_max   , :decimal , default: 1000.00
          preference :operator_max , :string  , default: :<


          acts_as_type :preferred_operator_min, [:>, :>=], %W[大于 大于等于]
          acts_as_type :preferred_operator_max, [:<, :<=], %W[小于 小于等于]

          def applicable?(promotable)
            promotable.respond_to?(:item_total)
          end

          def eligible?(promotable)
            item_total = promotable.item_total

            lower_limit_condition = item_total.send(preferred_operator_min, BigDecimal.new(preferred_amount_min.to_s))
            upper_limit_condition = item_total.send(preferred_operator_max, BigDecimal.new(preferred_amount_max.to_s))

            upper_limit_condition && lower_limit_condition
          end
        end
      end
    end
  end
end