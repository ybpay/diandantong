module Ddt
  module OrderService
    module Cart
      module Concern
        module AdjustTest
          extend ActiveSupport::Concern
          def test_adjust
            assert_difference "cart.adjustments.count" do
              cart.adjust(reason: :promotion, amount: -10, label: "label")
            end
          end

          def test_adjust_add_promotion_id
            cart.adjust(reason: :promotion, source: order_promotion.actions.first)
            assert cart.promotion_ids.include?(order_promotion.id)
          end

          def test_clear_promotion
            cart.adjust(reason: :promotion, source: order_promotion.actions.first)
            cart.clear_promotion
            assert_equal 0, cart.adjustments.promotion.count
            assert_equal 0, cart.promotion_ids.count
          end

          def test_add_promotion_relation_after_place
            cart.add(itemable)
            if cart.evaluate_promotion?
              order_promotion
              cart.update_promotion
              order = cart.place
              assert_equal 1, order.promotions.count
            end
          end

          def test_adjust_with_item_adjustments
            skip unless itemable.is_a? Ddt::Variant
            promotion = order_promotion_with_item_discount
            cart.add(itemable)
            cart.adjust(reason: :promotion, source: promotion.actions.first)
            assert_equal cart.adjustments.promotion.last.item_adjustments.count, 1
            assert_equal cart.adjustments.promotion.last.changed_values[:item_adjustments].length, 1
          end
        end
      end
    end
  end
end