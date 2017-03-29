module Ddt
  class Promotion
    module Rules
      module Event
        class UserTotalAmount < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          preference :total_amount, :decimal , default: 1000.00

          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::OrderPay)
          end

          def eligible?(promotable)
            return false if promotable.order.is_recharge?
            return false if promotable.order.vip_info.blank?
            current_total_amount = promotable.order.vip_info.total_amount
            order_total = promotable.order.total
            current_total_amount < preferred_total_amount && preferred_total_amount <= ( current_total_amount + order_total )
          end
        end
      end
    end
  end
end