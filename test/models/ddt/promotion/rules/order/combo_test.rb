require "test_helper"
module Ddt
  class Promotion
    module Rules
      module Order
        class ComboTest < TestCase::Base
          let(:combo1){ create :combo, branch: branch, shop: shop }
          let(:combo2){ create :combo, branch: branch, shop: shop }
          def test_eligible_match_all
            rule = create :promotion_rules_order_combo, preferred_match_policy: :match_all
            rule.combos << combo1
            rule.combos << combo2
            promotable = stub(combos: [combo1, combo2])
            assert_equal true, rule.eligible?(promotable)
            promotable = stub(combos: [combo1])
            assert_equal false, rule.eligible?(promotable)
          end

          def test_eligible_match_any
            rule = create :promotion_rules_order_combo, preferred_match_policy: :match_any
            rule.combos << combo1
            rule.combos << combo2
            promotable = stub(combos: [combo1])
            assert_equal true, rule.eligible?(promotable)
            promotable = stub(combos: [combo2])
            assert_equal true, rule.eligible?(promotable)
          end

          def test_eligible_match_none
            rule = create :promotion_rules_order_combo, preferred_match_policy: :match_none
            rule.combos << combo1
            promotable = stub(combos: [combo1])
            assert_equal false, rule.eligible?(promotable)
          end
        end
      end
    end
  end
end