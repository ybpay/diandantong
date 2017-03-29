
require 'test_helper'

module Ddt
  module CommonApi
    module V1
      module Order
        class PayItemsControllerTest < TestCase::Controller::CommonApi

          def setup
            @order = example_eat_in_hall_order
          end

          def test_create
            post :create, p(order_id: @order.id, pay_items: [{
                name_sym: "pay_on_face",
                amount: @order.total
              }], is_local_printed: false)
            assert_response 200
            assert_equal json["pay_items"].size, 1
          end

          def test_show
            @pay_item = @order.load_pay_item(pay_itemable)
            get :show, p(order_id: @order.id, id: @pay_item.id)
            assert_response 200
            assert_equal json["pay_items"].size, 1
          end

          def test_clear
            @order.create_pay_items([pay_itemable])
            post :clear, p(order_id: @order.id)
            assert_response 200
            assert_equal json["pay_items"].size, 0
          end

          def test_paid
            @pay_item = @order.load_pay_item(pay_itemable)
            post :paid, p(
              order_id: @order.id,
              id: @pay_item.id,
              paid_amount: 100,
              change: 100 - @order.total
            )
            assert_response 200
            assert_equal json["pay_items"][0]["state"], "paid"
          end

          def test_paid_all
            @order.create_pay_items([pay_itemable])
            post :paid_all, p(order_id: @order.id)
            assert_response 200
            assert_equal json["pay_item_state"], "paid"
          end

          def test_get_pay_online
            skip # TODO
          end

          def test_pay_by_seller_scan
            skip # TODO
          end

          private

            def pay_itemable
              OrderService::PayItemable.new(name_sym: :pay_on_face, amount: @order.total, shop: shop)
            end

        end
      end
    end
  end
end

