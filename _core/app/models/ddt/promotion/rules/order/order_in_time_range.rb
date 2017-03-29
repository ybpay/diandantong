module Ddt
  class Promotion
    module Rules
      module Order
        class OrderInTimeRange < ::Ddt::PromotionRule
          include Ddt::PromotionRuleModelName
          preference :start_at, :string, default: "18:00"
          preference :end_at, :string, default: "22:00"
          def applicable?(promotable)
            promotable.respond_to?(:place_time)
          end

          def eligible?(promotable)
            place_time = promotable.place_time.in_time_zone(self.shop.time_zone).strftime("%H:%M")
            preferred_start_at <= place_time &&
            preferred_end_at >= place_time
          end

        end
      end
    end
  end
end
