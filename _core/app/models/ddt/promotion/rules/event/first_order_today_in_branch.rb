module Ddt
  class Promotion
    module Rules
      module Event
        class FirstOrderTodayInBranch < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName

          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::OrderPay)
          end

          def eligible?(promotable)
            promotable.user.present? && promotable.user.orders.today.where(branch: self.promotion.branch).count == 1
          end
        end
      end
    end
  end
end