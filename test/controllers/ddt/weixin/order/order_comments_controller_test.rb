require "test_helper"
module Ddt
  module Weixin
    module Order
      class OrderCommentsControllerTest < TestCase::Controller::Weixin
        let(:order){
          cart = OrderService::Cart::EatInHall.new(branch: branch, user: user, table: table)
          cart.add(variant)
          order = cart.place
          order
        }
        setup do
        end

        concerning :Create do
          def test_create
            post :create, p(order_id: order.id, order_comment: { content: "content", rating: 4 })
            assert_response 200
            assert order.comment.present?
          end
        end
      end
    end
  end
end