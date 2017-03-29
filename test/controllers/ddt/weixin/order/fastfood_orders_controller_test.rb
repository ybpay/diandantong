require "test_helper"
require_relative "base_order_controller_test"
module Ddt
  module Weixin
    module Order
      class FastfoodOrdersControllerTest < TestCase::Controller::Weixin
        include BaseOrderControllerTest
        let(:cart){ OrderService::Cart::Fastfood.new(branch: branch, user: user) }
        let(:itemable){ variant }
        let(:order){
          cart = OrderService::Cart::Fastfood.new(branch: branch, user: user)
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
            assert_difference "branch.fastfood_orders.count" do
              post :create, p(order: { pay_method: :pay_on_face })
            end
            assert_response 200
          end
        end

        def test_hasten
          post :hasten, p(id: order.id)
          assert_response 200
        end

        def test_call_waiter
          post :call_waiter, p(id: order.id, service_name: "service_name")
          assert_response 200
        end
      end
    end
  end
end