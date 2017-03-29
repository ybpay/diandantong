module Ddt
  class Promotion
    module Rules
      module Order
        class FirstOrderInBranch < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          def applicable?(promotable)
            promotable.respond_to?(:user)
          end

          def eligible?(promotable)
            if promotable.user.present?
              orders_count = promotable.user.orders.where(branch: self.promotion.branch).count
              orders_count == (promotable.cart? ?  0 : 1)
            end
          end
        end
      end
    end
  end
end