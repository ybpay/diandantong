require "test_helper"
require_relative "base_order_controller_test"
module Ddt
  module Webpos
    module Order
      class FastfoodOrdersControllerTest < TestCase::Controller::Webpos
        include Ddt::Webpos::Order::BaseOrderControllerTest
        setup do
          sign_in worker
          @order = example_fastfood_order
        end

        def test_create
          sign_in waiter
          assert_change "branch.fastfood_orders.count" do
            post :create, shop_id: shop.id, branch_id: branch.id, cart: {
              line_items_attributes: [{
                itemable_type: "Ddt::Variant",
                itemable_id: variant.id,
                quantity: 1,
                }],
              note: "note",
              food_number: 22
            }
          end
          assert_response 200
        end
      end
    end
  end
end