require "test_helper"
module Ddt
  module Webpos
    module Order
      class LineItemsControllerTest < TestCase::Controller::Webpos
        setup do
          sign_in worker
          @order = example_eat_in_hall_order
        end

        def test_change_price
          @line_item = @order.line_items.first
          post :change_price, p(order_id: @order.id, id: @line_item.id, new_price: 1.00)
          assert_response 200
          assert_equal @order.reload.line_items.first.total, 1
        end
      end
    end
  end
end