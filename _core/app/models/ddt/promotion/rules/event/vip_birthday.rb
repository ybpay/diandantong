module Ddt
  class Promotion
    module Rules
      module Event
        class VipBirthday < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          preference :advance_days, :integer , default: 0

          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::VipBirthday)
          end

          def eligible?(promotable)
            true
          end

        end
      end
    end
  end
end
