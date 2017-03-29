module Ddt
  module OrderService
    module Order
      module Concern
        module AdjustTest
          extend ActiveSupport::Concern
          def test_adjust
            assert_difference "order.adjustments.count" do
              order.adjust(reason: :promotion, amount: -10, label: "label")
            end
          end

          concerning :Privilege do
            def test_privilege_discount
              skip unless itemable.is_a? Ddt::Variant
              assert_change "order.adjustments.privilege_discount.count" do
                order.privilege_discount(0.9, authorizer: worker)
              end
              assert_equal order.privilege_discount_adjustment.amount.to_f, -1
              assert_equal order.privilege_discount_adjustment.authorizer, worker
              assert_equal order.privilege_discount_adjustment.item_adjustments.count, 1
              assert_equal order.privilege_discount_adjustment.item_adjustments.first.amount.to_f, -1
              assert_equal order.privilege_discount_adjustment.item_adjustments.first.line_item_id, order.line_items.first.id
            end

            def test_privilege_reduction
              assert_change "order.adjustments.privilege_reduction.count" do
                order.privilege_reduction(1, authorizer: worker)
              end
              assert_equal order.privilege_reduction_adjustment.amount, -1
              assert_equal order.privilege_reduction_adjustment.authorizer, worker
            end

            def test_privilege_free
              assert_change "order.adjustments.privilege_free.count" do
                order.privilege_free(authorizer: worker)
                order.update_total_and_save
              end
              assert_equal order.privilege_free_adjustment.authorizer, worker
              assert_equal order.privilege_free_adjustment.item_adjustments.count, 1
              assert_equal order.privilege_free_adjustment.item_adjustments.first.amount, order.privilege_free_adjustment.amount
              assert_equal order.privilege_free_adjustment.item_adjustments.first.is_apportion, true
              assert_equal order.line_items.first.apportion_adjustment_total, order.privilege_free_adjustment.amount
              assert_equal order.line_items.first.apportion_adjust_reason, "privilege_free"
            end

            def test_cancel_privilege_adjustment
              order.privilege_free(authorizer: worker)
              assert_change "order.adjustments.privilege.count" do
                order.cancel_privilege_adjustment
              end
            end
          end

          concerning :Moling do
            def test_moling_erase_with_0
              order.stubs(:total).returns(1.11)
              order.branch.stubs(:moling_type).returns(:moling_erase)
              order.branch.stubs(:moling_precision).returns(:moling_yuan)
              order.moling
              assert_equal order.moling_amount, -0.11
            end

            def test_moling_erase_with_1
              order.stubs(:total).returns(1.11)
              order.branch.stubs(:moling_type).returns(:moling_erase)
              order.branch.stubs(:moling_precision).returns(:moling_jiao)
              order.moling
              assert_equal order.moling_amount, -0.01
            end

            def test_moling_round_with_0_more
              order.stubs(:total).returns(1.50)
              order.branch.stubs(:moling_type).returns(:moling_round)
              order.branch.stubs(:moling_precision).returns(:moling_yuan)
              order.moling
              assert_equal order.moling_amount, 0.5
            end

            def test_moling_round_with_0_less
              order.stubs(:total).returns(1.40)
              order.branch.stubs(:moling_type).returns(:moling_round)
              order.branch.stubs(:moling_precision).returns(:moling_yuan)
              order.moling
              assert_equal order.moling_amount, -0.4
            end

            def test_cancel_moling
              order.stubs(:total).returns(1.11)
              order.moling
              order.cancel_moling
              assert order.moling_blank?
            end
          end

          concerning :VipDiscount do
            def test_update_vip_discount_adjustment
              skip unless itemable.is_a? Ddt::Variant
              order.vip_discount = 0.9
              order.update_vip_discount_adjustment
              assert order.vip_discount_adjustment.present?
              assert_equal order.vip_discount_adjustment.item_adjustments.count, 1
              assert_equal order.vip_discount_adjustment.item_adjustments.first.line_item_id, order.line_items.first.id
            end

            def test_update_vip_discount_adjustment_destroy
              skip unless itemable.is_a? Ddt::Variant
              order.vip_discount = 0.9
              order.update_vip_discount_adjustment
              order.vip_discount = 1
              order.update_vip_discount_adjustment
              assert order.vip_discount_adjustment.blank?
            end
          end

          concerning :Coupon do
            def test_update_coupon_adjustment
              skip unless itemable.is_a? Ddt::Variant
              order.apply_coupon(coupon)
              order.stubs(:item_total).returns(1)
              assert_change ["order.adjustments.coupon.count"] do
                order.update_coupon_adjustment
              end
              assert_equal nil, coupon.applied_to_order_id
            end

            def test_apply_coupon
              skip unless itemable.is_a? Ddt::Variant
              assert_change ["order.total", "order.adjustments.coupon.count"] do
                order.apply_coupon(coupon)
              end
              assert_equal order.id, coupon.applied_to_order_id
            end

            def test_apply_product_coupon
              skip unless itemable.is_a? Ddt::Variant
              assert_change ["order.total", "order.adjustments.coupon.count"] do
                order.apply_coupon(product_coupon)
              end
              assert_equal order.adjustments.coupon.count, 1
              assert_equal order.adjustments.coupon.first.item_adjustments.count, 1
              assert_equal order.line_items.first.adjustment_total, -variant.price
              assert_equal product_coupon.reload.applied_to_order_id, order.id
            end

            def test_rollback_coupon
              skip unless itemable.is_a? Ddt::Variant
              order.apply_coupon(coupon)
              assert_change ["order.total", "order.adjustments.coupon.count"] do
                order.rollback_coupon
              end
              assert_equal nil, coupon.applied_to_order_id
            end

            def test_rollback_product_coupon
              skip unless itemable.is_a? Ddt::Variant
              order.apply_coupon(product_coupon)
              assert_change ["order.total", "order.adjustments.coupon.count"] do
                order.rollback_coupon
              end
              assert_equal order.adjustments.coupon.count, 0
              assert_equal order.line_items.first.adjustment_total, 0
              assert_equal product_coupon.reload.applied_to_order_id, nil
            end
          end

          concerning :Voucher do
            def test_apply_voucher
              assert_change ["order.total", "order.adjustments.voucher.count"] do
                order.apply_voucher(voucher, authorizer: worker)
              end
              assert_equal order.id, voucher.applied_to_order_id
            end

            def test_rollback_voucher
              order.apply_voucher(voucher, authorizer: worker)
              assert_change ["order.total", "order.adjustments.voucher.count"] do
                order.rollback_voucher
              end
              assert_equal nil, voucher.applied_to_order_id
            end
          end

          concerning :Promotion do
            def test_adjust_with_promotion
              skip unless itemable.is_a? Ddt::Variant
              promotion = order_promotion_with_item_discount
              skip unless order.evaluate_promotion?
              assert_equal order.adjustments.promotion.count, 1
              assert_equal order.adjustments.promotion.last.item_adjustments.count, 1
            end

            def test_adjust_with_promotion_append
              skip unless itemable.is_a? Ddt::Variant
              promotion = order_promotion_with_item_discount
              skip unless order.evaluate_promotion?
              order
              order.append(itemable.to_line_itemable)
              assert_equal order.adjustments.promotion.count, 1
              assert_equal order.adjustments.promotion.last.item_adjustments.count, 2
              assert_equal order.adjustments.promotion.last.item_adjustments.first.line_item_id, order.line_items.first.id
              assert_equal order.adjustments.promotion.last.item_adjustments.last.line_item_id, order.line_items.last.id
              assert_equal order.adjustments.promotion.last.item_adjustments.first.amount, order.line_items.first.adjustment_total
              assert_equal order.adjustments.promotion.last.item_adjustments.last.amount, order.line_items.last.adjustment_total
            end

            def test_adjust_with_promotion_subtract
              skip unless itemable.is_a? Ddt::Variant
              promotion = order_promotion_with_item_discount
              skip unless order.evaluate_promotion?
              order
              subtractable = OrderService::Subtractable.new(order: order, line_item_id: order.line_items.first.id, quantity: 1)
              order.subtract(subtractable)
              assert_equal order.adjustments.promotion.count, 0
              assert_equal order.line_items.first.adjustment_total, 0
            end
          end

          concerning :DiscountPlan do
            def test_adjust_with_discount_plan
              skip unless itemable.is_a? Ddt::Variant
              plan = discount_plan
              order.add_discount_plan(plan)
              order.update_total_and_save
              assert_equal order.discount_plan_adjustment.amount, -1
              assert_equal order.discount_plan_adjustment.item_adjustments.count, 1
              assert_equal order.discount_plan_adjustment.item_adjustments.first.amount, -1
            end

            def test_adjust_with_cancel_discount_plan
              skip unless itemable.is_a? Ddt::Variant
              order.add_discount_plan(discount_plan)
              order.update_total_and_save
              order.cancel_discount_plan
              order.update_total_and_save
              assert order.discount_plan_adjustment.blank?
            end
          end
        end
      end
    end
  end
end
