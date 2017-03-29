require "test_helper"
module Ddt
  module Webpos
    module ExtendedForm
      class OrdersControllerTest < TestCase::Controller::Webpos
        setup do
          sign_in cashier
        end
        def test_show
          order = example_eat_in_hall_order
          pay_itemable = OrderService::PayItemable.new(pay_method_name_sym: :pay_on_face, amount: order.total, shop: shop)
          order.load_pay_item(pay_itemable)
          get :show, p(id: order.id, format: :html)
          assert_response 200
          assert_template layout: 'ddt/layouts/webpos/extended_form'
        end
      end
    end
  end
end