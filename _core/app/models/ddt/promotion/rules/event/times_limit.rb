module Ddt
  class Promotion
    module Rules
      module Event
        class TimesLimit < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          preference :times   , :integer , default: 1

          def applicable?(promotable)
            true
          end

          def eligible?(promotable)
            promotable.user.present? && promotion.promotion_events.where(user: promotable.user).count < preferred_times
          end
        end
      end
    end
  end
end