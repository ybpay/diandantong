require "test_helper"
module Ddt
  module OrderService
    module Concern
      class RelationTest < TestCase::Base
        let(:order){example_fastfood_order}
        let(:promotion){ create :order_promotion, branch: branch, shop: shop }
        def test_belongs_to
          assert_equal shop, order.shop
        end

        def test_has_one
          assert_equal nil, order.comment
        end

        def test_has_many
          assert_equal 0, order.order_calls.count
        end

        concerning :Habts do
          def test_habts_get_ids
            order.add_promotion(promotion)
            assert_equal promotion.id, order.promotion_ids.first
          end

          def test_habts_set_ids
            order.promotion_ids = [promotion.id]
            assert_equal promotion, order.promotions.first
          end

          def test_habts_relation
            order.add_promotion(promotion)
            assert_equal promotion, order.promotions.first
          end

          def test_habts_clear
            order.add_promotion(promotion)
            order.clear_promotions
            assert_equal 0, order.promotions.count
          end

          def test_habts_add
            order.add_promotion(promotion)
            assert_equal 1, order.promotions.count
          end
        end
      end
    end
  end
end