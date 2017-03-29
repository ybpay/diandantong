module Ddt
  class Promotion
    module Rules
      module Event
        class FirstOrderInShop < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName

          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::OrderPay)
          end

          def eligible?(promotable)
            promotable.user.present? && promotable.user.placed_orders_count == 1
          end
        end
      end
    end
  end
end