require "test_helper"
require_relative "./base_test"
module Ddt
  module OrderService
    module Cart
      class ReservationTest < TestCase::Base
        include OrderService::Cart::BaseTest
        let(:reservation_time_point){ table_zone.reservation_time_points.first }
        let(:reservation_info){ Ddt::ReservationInfo.new(branch: branch, shop: shop, reservation_date: 1.day.since, reservation_time_point: reservation_time_point, name: "name", phone: generate(:phone), gender: :male)}
        let(:cart){ OrderService::Cart::Reservation.new(branch: branch, prepayment_type: :prepay_for_table, reservation_info: reservation_info) }
        let(:cart_with_pay_method){ OrderService::Cart::Reservation.new(branch: branch, prepayment_type: :prepay_for_table, reservation_info: reservation_info, pay_method: :pay_on_arrive) }
        let(:itemable){ variant }
        let(:cart_class){ OrderService::Cart::Reservation }

        def test_amount_for_pay_prepay_for_table
          table_zone = create(:table_zone, reservation_price: 100.0)
          reservation_info = Ddt::ReservationInfo.new(table_zone: table_zone)
          cart = OrderService::Cart::Reservation.new(branch: branch, prepayment_type: :prepay_for_table, reservation_info: reservation_info)
          assert_equal 100, cart.amount_for_pay.to_f
        end

        def test_amount_for_pay_prepay_for_table
          table_zone = create(:table_zone, reservation_price_percent: 50)
          reservation_info = Ddt::ReservationInfo.new(table_zone: table_zone)
          cart = OrderService::Cart::Reservation.new(branch: branch, prepayment_type: :prepay_for_order, reservation_info: reservation_info)
          variant = create(:product, price: 100, branch: branch).master
          cart.add(variant)
          assert_equal 50, cart.amount_for_pay.to_f
        end

        def test_check_reservation_info
          reservation_info = Ddt::ReservationInfo.new(branch: branch, shop: shop, name: "name", gender: :male)
          cart = OrderService::Cart::Reservation.new(branch: branch, prepayment_type: :prepay_for_table, reservation_info: reservation_info)
          cart.check_reservation_info
          assert cart.errors.present?
        end

        def test_reservation_info_save
          cart.add(itemable)
          order = cart.place
          assert order.reservation_info.present?
        end

        concerning :SessionStore do
          def test_to_session
            session = cart.to_session
            assert session[:reservation_time_point_id].present?
          end

          def test_cart_options_from_session
            options = cart_class.cart_options_from_session(cart.to_session)
            assert options[:reservation_info].present?
          end
        end

        def test_update_reservation_info
          skip
        end

        def test_update_prepayment_type_for_table
          cart.update_prepayment_type(:prepay_for_table)
          assert_equal 1, cart.adjustments.reservation_table_price.count
        end

        def test_update_prepayment_type_for_order
          cart.update_prepayment_type(:prepay_for_order)
          assert_equal 0, cart.adjustments.reservation_table_price.count
        end
      end
    end
  end
end