require "test_helper"
module Ddt
  module Webpos
    module Order
      class PayItemsControllerTest < TestCase::Controller::Webpos
        setup do
          sign_in worker
          @order = example_eat_in_hall_order
        end

        def test_paid
          pay_itemable = OrderService::PayItemable.new(name_sym: :pay_on_face, amount: @order.total, shop: shop)
          @pay_item = @order.load_pay_item(pay_itemable)
          post :paid, p(order_id: @order.id, id: @pay_item.id)
          assert_response 200
          assert_equal json["state"], "paid"
        end

        def test_get_pay_online
          skip # TODO
        end

        def test_pay_by_seller_scan
          skip # TODO
        end

        def test_show
          skip # TODO
        end
      end
    end
  end
end
