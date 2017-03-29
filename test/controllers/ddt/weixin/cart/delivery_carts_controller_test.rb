require "test_helper"
require_relative "base_cart_controller_test"
require_relative "base_cart_coupon_controller_test"
module Ddt
  module Weixin
    module Cart
      class DeliveryCartsControllerTest < TestCase::Controller::Weixin
        include Weixin::Cart::BaseCartControllerTest
        include Weixin::Cart::BaseCartCouponControllerTest
        let(:address){ create(:address, base_user: user)}
        let(:itemable){ variant }
        let(:cart){ OrderService::Cart::Delivery.new(branch: branch, user: user) }
        setup do
        end

        def test_update_shipment
          post :update_shipment, p(shipment: { delivery_zone_id: delivery_zone.id, address_id: address.id})
          assert_response 200
        end
      end
    end
  end
end