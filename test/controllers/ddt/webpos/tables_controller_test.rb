require "test_helper"
module Ddt
  module Webpos
    class TablesControllerTest < TestCase::Controller::Webpos
      setup do
        sign_in waiter
      end

      def test_index
        table_zone
        get :index, p
        assert_response 200
        assert_equal json.size, 2
      end

      def test_show
        get :show, p(id: table.id)
        assert_response 200
        assert_equal json["id"], table.id
      end

      def test_open
        post :open, p(id: table.id, table: { guest_num: 2 })
        assert_response 200
      end

      def test_get_changed_tables
        skip # TODO
      end

      def test_update_guest_num
        post :update_guest_num, p(id: table.id, guest_num: 10)
        assert_response 200
        assert_equal json["guest_num"], 10
      end

      concerning :GetReservationTable do
        def test_get_reservation_tables
          order = reservation_order
          reservation_time_point = table_zone.reservation_time_points.first
          post :get_reservation_tables, p(reservation_date: 1.day.since.strftime("%F"), time_point_id: reservation_time_point.id)
          assert_response 200
          assert_equal order.id, json[0]["reservation_info"]["order_id"]
        end

        private
        def reservation_order
          reservation_time_point = table_zone.reservation_time_points.first
          reservation_info = ReservationInfo.new(branch: branch, shop: shop, reservation_date: 1.day.since, reservation_time_point: reservation_time_point, table: table, name: "name", phone: generate(:phone), gender: :male)
          cart = OrderService::Cart::Reservation.new(branch: branch, prepayment_type: :prepay_for_table, reservation_info: reservation_info, pay_method: :pay_on_arrive, track_from: :FromWebpos)
          order = cart.place
          order
        end
      end

      concerning :Clear do
        def test_clear
          order = paid_order
          post :clear, p(id: table.reload.id)
          assert_response 200
          assert_equal json["workflow_state"], "idle"
        end
        private
        def paid_order
          order = example_eat_in_hall_order
          pay_itemable = OrderService::PayItemable.new(name_sym: :pay_on_face, amount: order.total, shop: shop)
          pay_item = order.load_pay_item(pay_itemable)
          order.change_pay_item_to_paid(pay_item)
          order
        end
      end

      def test_check_out
        order = example_eat_in_hall_order
        post :check_out, p(id: table.id, terminal_id: "terminal_id")
        assert_response 200
      end

      def test_cancel_check_out
        order = example_eat_in_hall_order
        table.reload.check_out
        post :cancel_check_out, p(id: table.id, terminal_id: "terminal_id")
        assert_response 200
      end
    end
  end
end
