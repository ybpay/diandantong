module Ddt
  class Promotion
    module Rules
      module Event
        class FirstFollow < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName

          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::UserFollow)
          end

          def eligible?(promotable)
            promotable.user.promotion_events.of_type(promotable.type).count == 1
          end

        end
      end
    end
  end
end