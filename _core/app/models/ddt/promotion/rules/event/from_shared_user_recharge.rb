module Ddt
  class Promotion
    module Rules
      module Event
        class FromSharedUserRecharge < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName

          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::FromSharedUserRecharge)
          end

          def eligible?(promotable)
            true
          end
        end
      end
    end
  end
end