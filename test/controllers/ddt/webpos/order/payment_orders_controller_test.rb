require "test_helper"
require_relative "base_order_controller_test"
module Ddt
  module Webpos
    module Order
      class PaymentOrdersControllerTest < TestCase::Controller::Webpos
        include Ddt::Webpos::Order::BaseOrderControllerTest
        setup do
          sign_in worker
          @order = example_payment_order
        end
        def test_create
          assert_difference "branch.payment_orders.count" do
            post :create, p(amount: 100)
          end
          assert_response 200
        end
      end
    end
  end
end