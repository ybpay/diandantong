require "test_helper"
require_relative "base_order_controller_test"
module Ddt
  module Weixin
    module Order
      class DeliveryOrdersControllerTest < TestCase::Controller::Weixin
        include BaseOrderControllerTest
        let(:address){ create(:address, base_user: user)}
        let(:cart){ OrderService::Cart::Delivery.new(branch: branch, user: user) }
        let(:itemable){ variant }
        let(:order){
          cart = OrderService::Cart::Delivery.new(branch: branch, user: user)
          cart.add(itemable)
          order = cart.place
          order
        }
        setup do
        end

        concerning :Create do
          def test_create
            cart.add(itemable)
            set_cart_session(cart)
            assert_difference "branch.delivery_orders.count" do
              post :create, p(order: {
                pay_method: :pay_on_receive,
                shipment: {
                  delivery_zone_id: delivery_zone.id,
                  address_id: address.id
                }
              })
            end
            assert_response 200
          end
        end

        def test_hasten
          post :hasten, p(id: order.id)
          assert_response 200
        end

        def test_refresh_location
          post :refresh_location, p(id: order.id)
          assert_response 200
        end

        def test_ship
          assert_change "order.reload.shipment_state" do
            post :ship, p(id: order.id)
          end
          assert_response 200
        end
      end
    end
  end
end