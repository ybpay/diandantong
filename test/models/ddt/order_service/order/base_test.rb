require "test_helper"
require_relative "./concern/adjust_test"
require_relative "./concern/bind_scene_test"
require_relative "./concern/contents_test"
require_relative "./concern/deduction_test"
require_relative "./concern/pay_test"
require_relative "./concern/save_change_test"
require_relative "./concern/stock_sale_test"
require_relative "./concern/updater_test"
module Ddt
  module OrderService
    module Order
      module BaseTest
        extend ActiveSupport::Concern
        included do
          include OrderService::Order::Concern::AdjustTest
          include OrderService::Order::Concern::BindSceneTest
          include OrderService::Order::Concern::ContentsTest
          include OrderService::Order::Concern::DeductionTest
          include OrderService::Order::Concern::PayTest
          include OrderService::Order::Concern::SaveChangeTest
          include OrderService::Order::Concern::StockSaleTest
          include OrderService::Order::Concern::UpdaterTest
        end

        def test_update_place_orders_count
          order.stubs(:user).returns(user)
          order.stubs(:base_user_id).returns(user.id)
          assert_change %W[shop.reload.placed_orders_count branch.reload.placed_orders_count user.reload.placed_orders_count] do
            order.send(:update_place_orders_count)
          end
        end

        def test_reload
          order
          same_order = OrderService::Order::Base.find(order.id)
          same_order.update(track_from: "FromApp")
          same_order.save
          assert_change "order.track_from" do
            order.reload
          end
        end

        def test_reload_line_item_trace_points
          order
          assert order.line_item_trace_points.nil?
          order.reload_line_item_trace_points
          assert !order.line_item_trace_points.nil?
          assert order.line_items.present?
        end

        concerning :Place do

          def test_after_place
            assert_change "branch.orders.count" do
              order
            end
          end
        end

        concerning :Cancel do
          def test_cancel
            assert_change [
              "order.state", "order.canceled_at", "order.cancel_reason"] do
              order.cancel("cancel_reason")
            end
            assert_equal order.pay_items.count, 0
          end
        end

        concerning :Confirm do
          def test_confirm
            assert_change ["order.state", "order.confirmed_at"] do
              order.confirm
            end
          end
        end

        concerning :Complete do
          def test_complete
            order.confirm
            pay_itemable = OrderService::PayItemable.new(pay_method_name_sym: :pay_on_face, amount: order.total, shop: shop)
            pay_item = order.load_pay_item(pay_itemable)
            pay_item.change_to_paid
            order.update_pay_info
            assert_change ["order.state", "order.completed_at"] do
              order.complete
            end
          end
        end

        concerning :ChangeLineItemPrice do
          def test_change_line_item_price
            line_item = order.line_items.first
            assert_change ["order.total", "line_item.price", "line_item.change_price_at"] do
              order.change_line_item_price(line_item.id, 1.0)
            end
          end
        end

        concerning :Modified do
          def test_modified_at
            assert order.modified_at
          end
        end

        concerning :VipInfo do
          def test_change_vip_info
            vip_info = vip_user.vip_info
            line_item = order.line_items.first
            line_item.stubs(:vip_price).returns(1)
            line_item.stubs(:enable_discount).returns(true)
            assert_change ["vip_info.last_placed_at", "line_item.price"] do
              order.change_vip_info(vip_user.vip_info)
            end
          end

          def test_unbind_vip_info
            vip_info = vip_user.vip_info
            line_item = order.line_items.first
            line_item.stubs(:vip_price).returns(1)
            line_item.stubs(:enable_discount).returns(true)
            order.change_vip_info(vip_user.vip_info)
            assert_change ["line_item.price", "order.vip_discount", "order.vip_info"] do
              order.unbind_vip_info
            end
          end
        end

        concerning :DisabledPromotion do
          def test_add_disabled_promotion
            order.add_disabled_promotion(order_promotion)
            assert_equal order.disabled_promotions.count, 1
            assert_equal order.disabled_promotions.first, order_promotion
          end

          def test_remove_disabled_promotion
            order.add_disabled_promotion(order_promotion)
            order.remove_disabled_promotion(order_promotion)
            assert_equal order.disabled_promotions.count, 0
          end
        end
      end
    end
  end
end
