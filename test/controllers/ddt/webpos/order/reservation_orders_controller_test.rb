require "test_helper"
require_relative "base_order_controller_test"
module Ddt
  module Webpos
    module Order
      class ReservationOrdersControllerTest < TestCase::Controller::Webpos
        include Ddt::Webpos::Order::BaseOrderControllerTest
        setup do
          sign_in worker
          @order = example_reservation_order_prepay_for_order
        end

        def test_create
          reservation_time_point = table_zone.reservation_time_points.first
          assert_difference "branch.reservation_orders.count" do
            post :create, p(
                table_id: table.id,
                name: "name",
                phone: generate(:phone),
                gender: "male",
                reservation_date: 1.day.since,
                reservation_time_point_id: reservation_time_point.id
              )
          end
          assert_response 200
        end

        def test_change_to_eat_in_hall
          set_order_paid
          assert_difference "branch.eat_in_hall_orders.count" do
            post :change_to_eat_in_hall, p(id: @order.id, table_id: another_table.id)
          end
          assert_response 200
          assert_equal json["state"], "completed"
        end

        def test_bind_table
          post :bind_table, p(id: @order.id, table_id: table.id)
          assert_response 200
        end
      end
    end
  end
end