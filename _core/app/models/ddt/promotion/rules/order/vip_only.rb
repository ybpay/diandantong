module Ddt
  class Promotion
    module Rules
      module Order
        class VipOnly < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName

          def applicable?(promotable)
            promotable.respond_to?(:is_vip?)
          end

          def eligible?(promotable)
            promotable.is_vip?
          end
        end
      end
    end
  end
end