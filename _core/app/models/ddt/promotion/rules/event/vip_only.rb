module Ddt
  class Promotion
    module Rules
      module Event
        class VipOnly < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName

          def applicable?(promotable)
            promotable.try(:user).present?
          end

          def eligible?(promotable)
            promotable.try(:user).try(:vip?)
          end
        end
      end
    end
  end
end