module Ddt
  module OrderService
    module Cart
      module Concern
        module UpdaterTest
          extend ActiveSupport::Concern
          include do
          end

          def test_update_promotion
            cart.add(itemable)
            if cart.evaluate_promotion?
              order_promotion
              cart.update_promotion
              assert_equal 1, cart.adjustments.promotion.count
            end
          end

          concerning :Coupon do
            def test_update_coupon_adjustment
              cart.add(itemable)
              cart.coupon = coupon
              assert_change ["cart.adjustments.coupon.count"] do
                cart.update_coupon_adjustment
              end
            end

            def test_set_coupon
              cart.add(itemable)
              assert_change ["cart.coupon", "cart.adjustments.coupon.count"] do
                cart.set_coupon(coupon)
              end
            end

            def test_clear_coupon
              cart.add(itemable)
              cart.set_coupon(coupon)
              assert_change ["cart.coupon", "cart.adjustments.coupon.count"] do
                cart.clear_coupon
              end
            end
          end

          def test_update_vip_discount_adjustment
            cart.add(itemable)
            cart.vip_discount = 0.9
            if itemable.enable_discount
              assert_change ["cart.total", "cart.adjustments.vip_discount.count"] do
                cart.update_vip_discount_adjustment
              end
            else
              assert_no_change ["cart.total", "cart.adjustments.vip_discount.count"] do
                cart.update_vip_discount_adjustment
              end
            end
          end

          def test_update_discount_with_conflict
            skip unless itemable.is_a? Ddt::Variant
            promotion = order_promotion_with_item_discount
            cart.add(itemable)
            cart.vip_discount = 0.9
            cart.adjust(reason: :promotion, source: promotion.actions.first)
            cart.update_discount
            assert_equal cart.adjustments.promotion.last.item_adjustments.count, 1
            assert_equal cart.adjustments.promotion.last.changed_values[:item_adjustments].length, 1
            assert_equal cart.adjustments.vip_discount.count, 0
          end

        end
      end
    end
  end
end