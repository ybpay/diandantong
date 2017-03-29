require "test_helper"
require_relative "base_order_controller_test"
module Ddt
  module Weixin
    module Order
      class GrouponOrdersControllerTest < TestCase::Controller::Weixin
        include BaseOrderControllerTest
        let(:cart){ OrderService::Cart::Groupon.new(branch: branch, user: user) }
        let(:itemable){ create :groupon_version, shop: shop, branch: branch }
        let(:order){
          cart = OrderService::Cart::Groupon.new(branch: branch, user: user)
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
            assert_difference "branch.groupon_orders.count" do
              post :create, p(order: { pay_method: :pay_on_face })
            end
            assert_response 200
          end
        end
      end
    end
  end
end
