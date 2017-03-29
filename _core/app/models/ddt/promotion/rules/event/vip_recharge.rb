module Ddt
  class Promotion
    module Rules
      module Event
        class VipRecharge < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName

          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::OrderPay)
          end

          def eligible?(promotable)
            promotable.order.is_recharge?
          end
        end
      end
    end
  end
end