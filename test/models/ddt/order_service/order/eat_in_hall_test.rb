require "test_helper"
require_relative "./base_test"
require_relative "./concern/call_waiter_test"
require_relative "./concern/hastenable_test"
module Ddt
  module OrderService
    module Order
      class EatInHallTest < TestCase::Base
        include OrderService::Order::BaseTest
        include OrderService::Order::Concern::CallWaiterTest
        include OrderService::Order::Concern::HastenableTest
        let(:itemable){ variant }
        let(:order){ example_eat_in_hall_order }

        def test_after_place_action
          order
          assert table.reload.ordered?
          assert table.current_order?(order)
          assert order.order_ext.present?
        end

        def test_change_table
          travel_to 1.minute.ago do
            order
          end
          assert_change %w(table.reload.updated_at another_table.reload.updated_at) do
            order.change_table(another_table)
          end
          assert_equal 1, order.order_change_logs.change_table.count
          assert_equal another_table.id, order.table_id
          assert table.is_idle?
          assert_equal nil, table.current_order_id
          assert another_table.current_order_id, order.id
        end

        def test_merge_table
          another_order = nil
          travel_to 1.minute.ago do
            order
            cart = OrderService::Cart::EatInHall.new(table: another_table, branch: branch, track_from: :FromWebpos)
            cart.add(variant)
            another_order = cart.place
          end
          assert_change %w(table.reload.updated_at another_table.reload.updated_at) do
            order.merge_table(another_table)
          end
          order.reload
          another_order.reload
          assert table.idle?
          assert another_table.ordered?
          assert_equal 1, order.order_change_logs.merge_table.count
          assert_equal 1, order.order_change_logs.count
          assert_equal 1, another_order.order_change_logs.merge_table.count
          assert_equal 2, another_order.order_change_logs.order_place.count
          assert_equal 0, order.line_items.count
          assert_equal 2, another_order.line_items.count
          assert_equal 2, another_order.reload_line_item_trace_points.line_item_trace_points.count
          assert order.merged?
          assert_equal 0.0, order.total.to_f
          assert_equal variant.price * 2, another_order.total.to_f
        end

        def test_move_itemable
          another_order = nil
          travel_to 1.minute.ago do
            order
            cart = OrderService::Cart::EatInHall.new(table: another_table, branch: branch, track_from: :FromWebpos)
            cart.add(variant)
            another_order = cart.place
          end
          moveable = OrderService::Moveable.new(order: order, line_item_id: order.line_items.first.id, quantity: 1)
          assert_change %w(table.reload.updated_at another_table.reload.updated_at) do
            order.move_itemable(another_table, [moveable])
          end
          order.reload
          another_order.reload
          assert another_table.ordered?
          assert_equal 1, order.order_change_logs.move_itemable.count
          assert_equal 2, order.line_items.count
          assert_equal 0, order.line_items.active.count
          assert_equal 1, order.line_items.moved.count
          assert_equal 1, order.reload_line_item_trace_points.line_item_trace_points.count
          assert_equal 1, order.reload_line_item_trace_points.line_item_trace_points.canceled.count
          assert_equal 1, another_order.order_change_logs.move_itemable.count
          assert_equal 2, another_order.line_items.count
          assert_equal 1, another_order.line_items.from_move.count
          assert_equal 2, another_order.reload_line_item_trace_points.line_item_trace_points.count
          assert_equal 2, another_order.reload_line_item_trace_points.line_item_trace_points.pending.count
          assert_equal 0.0, order.total.to_f
          assert_equal variant.price * 2, another_order.total.to_f
        end

        def test_bind_reservation_order
          reservation_order = example_reservation_order_prepay_for_table
          pay_itemable = OrderService::PayItemable.new(name_sym: :pay_on_face, amount: reservation_order.amount_for_pay, shop: shop)
          reservation_order.load_pay_item(pay_itemable)
          reservation_order.pay_all_pay_items
          order = example_eat_in_hall_order
          assert_change [
            "order.total",
            "order.adjustments.prepay_for_reservation_table.count",
            "reservation_order.state",
            ] do
              order.bind_reservation_order(reservation_order)
            end
          assert_equal order.related_order_id, reservation_order.id
          assert_equal reservation_order.related_order_id, order.id
        end

        def test_update_guest_num
          order.update_guest_num(10)
          assert_equal order.guest_num, 10
          assert_equal order.table.guest_num, 10
        end

      end
    end
  end
end
