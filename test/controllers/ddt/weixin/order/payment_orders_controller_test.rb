require "test_helper"
require_relative "base_order_controller_test"
module Ddt
  module Weixin
    module Order
      class PaymentOrdersControllerTest < TestCase::Controller::Weixin
        include BaseOrderControllerTest
        let(:cart){ OrderService::Cart::Payment.new(branch: branch, user: user) }
        let(:order){
          cart = OrderService::Cart::Payment.new(branch: branch, user: user, payment_price: 10)
          order = cart.place
          order
        }
        setup do
        end

        concerning :Create do
          def test_create
            assert_difference "branch.payment_orders.count" do
              post :create, p(order: { pay_method: :pay_on_face , amount: 10})
            end
            assert_response 200
          end
        end
      end
    end
  end
end