module Ddt
  class Promotion
    module Rules
      module Order
        class OneUsePerUser < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          def applicable?(promotable)
            promotable.respond_to?(:user)
          end

          def eligible?(promotable)
            promotable.user.present? && !promotion.used_by?(promotable.user, excluded_orders: [promotable])
          end
        end
      end
    end
  end
end