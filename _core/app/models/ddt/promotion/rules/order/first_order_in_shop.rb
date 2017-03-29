module Ddt
  class Promotion
    module Rules
      module Order
        class FirstOrderInShop < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          def applicable?(promotable)
            promotable.respond_to?(:user)
          end

          def eligible?(promotable)
            if promotable.user.present?
              promotable.user.placed_orders_count == (promotable.cart? ? 0 : 1)
            end
          end
        end
      end
    end
  end
end