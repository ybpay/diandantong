require "test_helper"
require_relative "base_order_controller_test"
module Ddt
  module Weixin
    module Order
      class ReservationOrdersControllerTest < TestCase::Controller::Weixin
        include BaseOrderControllerTest
        let(:cart){ OrderService::Cart::Reservation.new(branch: branch, user: user) }
        let(:reservation_time_point){ table_zone.reservation_time_points.first}
        let(:order){
          reservation_info = ReservationInfo.new(branch: branch, shop: shop, reservation_date: 1.day.since, reservation_time_point: reservation_time_point, name: "name", phone: generate(:phone), gender: :male)
          cart = OrderService::Cart::Reservation.new(branch: branch, user: user, prepayment_type: :prepay_for_table, reservation_info: reservation_info, pay_method: :pay_on_arrive, track_from: :FromWechat)
          order = cart.place
          order
        }
        setup do
        end

        concerning :Create do
          def test_create
            cart.update_reservation_info(reservation_time_point: reservation_time_point, reservation_date: 1.day.since)
            set_cart_session(cart)
            assert_difference "branch.reservation_orders.count" do
              post :create, p(order: { pay_method: :pay_on_face , prepayment_type: :prepay_for_table, name: "name", phone: "1354875486", gender: "male"})
            end
            assert_response 200
          end
        end
      end
    end
  end
end