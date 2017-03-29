require "test_helper"
require_relative "base_cart_controller_test"
module Ddt
  module Weixin
    module Cart
      class ReservationCartsControllerTest < TestCase::Controller::Weixin
        include Weixin::Cart::BaseCartControllerTest
        let(:itemable){ variant }
        let(:cart){ OrderService::Cart::Reservation.new(branch: branch, user: user)}
        setup do
        end

        def test_update_reservation_info
          skip
        end
      end
    end
  end
end