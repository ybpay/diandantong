require "test_helper"
require_relative "./base_test"
require_relative "./concern/hastenable_test"
module Ddt
  module OrderService
    module Order
      class DeliveryTest < TestCase::Base
        include OrderService::Order::BaseTest
        include OrderService::Order::Concern::HastenableTest
        let(:itemable){ variant }
        let(:order){ example_delivery_order }

        def test_start_shipment
          travel_to 1.hour.ago do
            order
          end
          assert_change ["order.updated_at", "order.shipment_state"] do
            order.start_shipment
          end
          assert_equal "shipping", order.shipment_state
          assert_equal "shipping", order.shipment.state
        end

        def test_ship_shipment
          travel_to 1.hour.ago do
            order
          end
          assert_change ["order.updated_at", "order.shipment_state"] do
            order.ship_shipment
          end
          assert_equal "shipped", order.shipment_state
          assert_equal "shipped", order.shipment.state
        end

        def test_cancel_shipment
          travel_to 1.hour.ago do
            order
          end
          assert_change ["order.updated_at", "order.shipment_state"] do
            order.cancel_shipment
          end
          assert_equal "canceled", order.shipment_state
          assert_equal "canceled", order.shipment.state
        end
      end
    end
  end
end