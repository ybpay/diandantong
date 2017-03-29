require "test_helper"
module Ddt
  class Promotion
    module Rules
      module Order
        class OrderInTimeRangeTest < TestCase::Base
          def test_eligible
            rule = create :promotion_rules_order_order_in_time_range, preferred_start_at: "10:00", preferred_end_at: "12:00", shop: shop
            promotable = stub(place_time: DateTime.parse("2016-04-21 11:00:00 +0800"))
            assert rule.eligible?(promotable)
          end
        end
      end
    end
  end
end