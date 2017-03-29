require "test_helper"
require_relative "./concern/contents_test"
require_relative "./concern/adjust_test"
require_relative "./concern/pay_test"
require_relative "./concern/updater_test"
module Ddt
  module OrderService
    module Cart
      module BaseTest
        extend ActiveSupport::Concern
        included do
          include OrderService::Cart::Concern::ContentsTest
          include OrderService::Cart::Concern::AdjustTest
          include OrderService::Cart::Concern::PayTest
          include OrderService::Cart::Concern::UpdaterTest
        end

        def test_initialize_base_without_branch
          assert_raises KeyError do
            cart_class.new
          end
        end

        def test_initialize_base_with_line_itemables
          cart = cart_class.new(branch: branch, line_itemables: [itemable.to_line_itemable])
          assert_equal cart.line_items.count, 1
        end

        def test_initialize_base_with_form_contentables
          form_contentables = OrderService::FormContentable.init_list([
            { form_element_id: form_element_text.id, content: "content"},
            { form_element_id: form_element_select.id, type: :quote, content: form_element_select.form_elements.first.id }
          ])
          cart = cart_class.new(branch: branch, form_contentables: form_contentables)
          assert_equal cart.form_contents.count, 2
        end

        def test_to_options_base
          cart = cart_class.new(branch: branch, line_itemables: [itemable.to_line_itemable])
          assert_equal cart.to_options[:state], :pending
        end

        concerning :Place do
          def test_place_base
            cart.add(itemable)
            order = cart.place
            assert order.id.present?
            assert order.number.present?
          end

          def test_place_base_with_form_contents
            form_contentables = OrderService::FormContentable.init_list([
              { form_element_id: form_element_text.id, content: "content"},
              { form_element_id: form_element_select.id, type: :quote, content: form_element_select.form_elements.first.id }
            ])
            cart.add(itemable)
            cart.update_form_contents(form_contentables)
            order = cart.place
            assert_equal order.form_contents.count, 2
          end

          def test_place_base_pay_item_state
            cart.add(itemable)
            order = cart.place
            assert order.pay_item_state.present?
          end

          def test_place_base_has_order_place_change_log
            cart.add(itemable)
            order = cart.place
            assert order.order_change_logs.first.is_order_place?
          end

          def test_place_base_has_line_item_trace_point
            cart.add(itemable)
            order = cart.place
            order = OrderService::Order::Base.includes(:line_item_trace_points).find(order.id)
            if itemable.is_a?(Variant) || itemable.is_a?(ComboPackage)
              assert order.line_item_trace_points.count > 0
            else
              assert order.line_item_trace_points.count == 0
            end
          end

          def test_place_base_with_coupon
            cart.add(itemable)
            cart.set_coupon(coupon)
            order = cart.place
            assert_equal order.adjustments.coupon.count, 1
            assert_equal coupon.reload.applied_to_order_id, order.id
          end

          def test_place_base_with_product_coupon
            skip unless itemable.is_a? Ddt::Variant
            cart.add(itemable)
            cart.set_coupon(product_coupon)
            order = cart.place
            assert_equal order.adjustments.coupon.count, 1
            assert_equal order.adjustments.coupon.first.item_adjustments.count, 1
            assert_equal order.line_items.first.adjustment_total, -variant.price
            assert_equal product_coupon.reload.applied_to_order_id, order.id
          end

          def test_place_with_card_deduction
            cart.add(itemable)
            cart.user = vip_user
            cart.add_card_deduction(1)
            order = cart.place
            assert_equal order.adjustments.card_deduction.first.amount, -1
            assert order.card_deduction.present?
          end

          def test_place_with_credits_deduction
            skip unless itemable.is_a? Ddt::Variant
            cart.add(itemable)
            cart.user = vip_user
            cart.add_credits_deduction(1)
            order = cart.place
            assert_equal order.adjustments.credits_deduction.first.amount, -0.01
            assert order.credits_deduction.present?
          end

          def test_place_with_vip_discount
            skip unless itemable.is_a? Ddt::Variant
            cart.add(itemable)
            cart.user = vip_user
            cart.vip_discount = vip_user.vip_discount
            order = cart.place
            assert_equal order.adjustments.vip_discount.count, 1
            assert_equal order.adjustments.vip_discount.first.item_adjustments.count, 1
            assert_equal order.line_items.first.adjustment_total, -variant.price * (1 - vip_user.vip_discount)
          end
        end

        def test_check_stock_is_enough
          itemable.stubs(:stock_enough?).returns(false)
          cart.add(itemable)
          cart.check_stock_is_enough
          assert cart.errors.present?
        end

        def test_check_collection_attr_valid
          cart.add(itemable)
          cart.line_items.first.price = -1
          cart.check_collection_attr_valid
          assert cart.errors[:line_items].present?
        end

        def test_check_user_blocked
          cart.user = user
          user.is_blocked = true
          cart.check_user_blocked
          assert cart.errors.present?
        end

        def test_check_vip_card_pay_amount_enough
          cart.user = user
          cart.pay_method = :vip_card_pay
          cart.add(itemable)
          cart.check_vip_card_pay_amount_enough
          assert cart.errors.present?
        end

        def test_check_item_count
          cart.check_item_count
          assert cart.errors.present?
        end

        def test_check_deduction_amount_enough
          cart.user = user
          cart.add_card_deduction(1)
          cart.check_deduction_amount_enough
          assert cart.errors.present?
        end

        def test_check_pay_method
          cart.pay_method = cart.pay_method_blacklist.first
          cart.check_pay_method
          assert cart.errors.present?
        end

        def test_not_evaluate_promotion_in_webpos
          cart.track_from = :FromWebpos
          branch.stubs(:promotion_in_webpos?).returns(false)
          assert_equal false, cart.evaluate_promotion?
        end

        concerning :VipPrice do
          def test_line_item_vip_price_1_1_0
            itemable.stubs(:price).returns(10)
            itemable.stubs(:vip_price).returns(8)
            itemable.stubs(:enable_discount).returns(true)
            vip_user.vip_info.stubs(:discount).returns(1)
            cart = cart_class.new(branch: branch, user: vip_user, line_itemables: [itemable.to_line_itemable])
            line_item = cart.line_items.first
            assert_equal 8, line_item.price
            assert_equal 0, cart.adjustments.vip_discount.count
          end

          def test_line_item_vip_price_1_0_0
            itemable.stubs(:price).returns(10)
            itemable.stubs(:vip_price).returns(8)
            itemable.stubs(:enable_discount).returns(false)
            vip_user.vip_info.stubs(:discount).returns(1)
            cart = cart_class.new(branch: branch, user: vip_user, line_itemables: [itemable.to_line_itemable])
            line_item = cart.line_items.first
            assert_equal 10, line_item.price
            assert_equal 0, cart.adjustments.vip_discount.count
          end

          def test_line_item_vip_price_1_1_1
            itemable.stubs(:price).returns(10)
            itemable.stubs(:vip_price).returns(8)
            itemable.stubs(:enable_discount).returns(true)
            vip_user.vip_info.stubs(:discount).returns(0.8)
            cart = cart_class.new(branch: branch, user: vip_user, line_itemables: [itemable.to_line_itemable])
            line_item = cart.line_items.first
            assert_equal 8, line_item.price
            assert_equal 1, cart.adjustments.vip_discount.count
            assert_equal -1.6, cart.adjustments.vip_discount.first.amount
          end

          def test_line_item_vip_price_1_0_1
            itemable.stubs(:price).returns(10)
            itemable.stubs(:vip_price).returns(8)
            itemable.stubs(:enable_discount).returns(false)
            vip_user.vip_info.stubs(:discount).returns(0.8)
            cart = cart_class.new(branch: branch, user: vip_user, line_itemables: [itemable.to_line_itemable])
            line_item = cart.line_items.first
            assert_equal 10, line_item.price
            assert_equal 0, cart.adjustments.vip_discount.count
          end

          def test_line_item_vip_price_0_1_0
            itemable.stubs(:price).returns(10)
            itemable.stubs(:vip_price).returns(10)
            itemable.stubs(:enable_discount).returns(true)
            vip_user.vip_info.stubs(:discount).returns(1)
            cart = cart_class.new(branch: branch, user: vip_user, line_itemables: [itemable.to_line_itemable])
            line_item = cart.line_items.first
            assert_equal 10, line_item.price
            assert_equal 0, cart.adjustments.vip_discount.count
          end

          def test_line_item_vip_price_0_0_0
            itemable.stubs(:price).returns(10)
            itemable.stubs(:vip_price).returns(10)
            itemable.stubs(:enable_discount).returns(false)
            vip_user.vip_info.stubs(:discount).returns(1)
            cart = cart_class.new(branch: branch, user: vip_user, line_itemables: [itemable.to_line_itemable])
            line_item = cart.line_items.first
            assert_equal 10, line_item.price
            assert_equal 0, cart.adjustments.vip_discount.count
          end

          def test_line_item_vip_price_0_1_1
            itemable.stubs(:price).returns(10)
            itemable.stubs(:vip_price).returns(10)
            itemable.stubs(:enable_discount).returns(true)
            vip_user.vip_info.stubs(:discount).returns(0.8)
            cart = cart_class.new(branch: branch, user: vip_user, line_itemables: [itemable.to_line_itemable])
            line_item = cart.line_items.first
            assert_equal 10, line_item.price
            assert_equal 1, cart.adjustments.vip_discount.count
            assert_equal -2, cart.adjustments.vip_discount.first.amount
          end

          def test_line_item_vip_price_0_0_1
            itemable.stubs(:price).returns(10)
            itemable.stubs(:vip_price).returns(8)
            itemable.stubs(:enable_discount).returns(false)
            vip_user.vip_info.stubs(:discount).returns(0.8)
            cart = cart_class.new(branch: branch, user: vip_user, line_itemables: [itemable.to_line_itemable])
            line_item = cart.line_items.first
            assert_equal 10, line_item.price
            assert_equal 0, cart.adjustments.vip_discount.count
          end
        end
      end
    end
  end
end
