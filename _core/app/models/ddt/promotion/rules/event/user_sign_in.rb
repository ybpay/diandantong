module Ddt
  class Promotion
    module Rules
      module Event
        class UserSignIn < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName

          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::UserSignIn)
          end

          def eligible?(promotable)
            true
          end

        end
      end
    end
  end
end