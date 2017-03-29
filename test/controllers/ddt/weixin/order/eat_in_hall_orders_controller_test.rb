require "test_helper"
require_relative "base_order_controller_test"
module Ddt
  module Weixin
    module Order
      class EatInHallOrdersControllerTest < TestCase::Controller::Weixin
        include BaseOrderControllerTest
        let(:cart){ OrderService::Cart::EatInHall.new(branch: branch, user: user, table: table) }
        let(:itemable){ variant }
        let(:order){
          cart = OrderService::Cart::EatInHall.new(branch: branch, user: user, table: table)
          cart.add(itemable)
          order = cart.place
          order
        }
        setup do
          # scanqrcode
          Ddt::OrderItemable::Adapter.new(store_type: 'for_merge_order', table_id: table.id).attach(session)
        end

        concerning :Create do
          def test_create
            cart.add(itemable)
            set_cart_session(cart)
            assert_difference "branch.eat_in_hall_orders.count" do
              post :create, p(order: { pay_method: :pay_on_face, guest_num: 2 })
            end
            assert_response 200
          end
        end

        def test_get_order_by_table
          order
          post :get_order_by_table, p(table_id: table.id)
          assert_response 200
          assert_equal order.id, json["id"]
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
