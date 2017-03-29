require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Order
      class ReservationTest < TestCase::Base
        include OrderService::Order::BaseTest
        let(:itemable){ variant }
        let(:order){ example_reservation_order_prepay_for_order }

        def test_update_reservation_info
          assert_change %w(order.reservation_name order.reservation_phone order.note) do
            order.update_reservation_info(name: "new_name", phone: "15715779856", gender: :male, note: "new_note")
          end
        end

        def test_change_to_eat_in_hall
          reservation_order = example_reservation_order_prepay_for_order
          pay_itemable = OrderService::PayItemable.new(name_sym: :pay_on_face, amount: reservation_order.get_amount_for_pay, shop: shop)
          reservation_order.load_pay_item(pay_itemable)
          reservation_order.pay_all_pay_items
          assert_change [
            "branch.eat_in_hall_orders.count",
          ] do
            eat_in_hall_order = reservation_order.change_to_eat_in_hall(table.id, note: "note")
            assert reservation_order.errors.blank?
            assert reservation_order.completed?
            assert_equal eat_in_hall_order.note, "note"
            assert_equal eat_in_hall_order.table_id, table.id
            assert_equal eat_in_hall_order.related_order_id, reservation_order.id
            assert_equal eat_in_hall_order.line_items.count, reservation_order.line_items.count
            assert_equal 1, eat_in_hall_order.adjustments.prepay_for_reservation_order.count
          end
        end

        def test_bind_table
          assert_change ["order.reservation_table_name", "order.reservation_info.table_id"] do
            order.bind_table(table)
          end
        end
      end
    end
  end
end