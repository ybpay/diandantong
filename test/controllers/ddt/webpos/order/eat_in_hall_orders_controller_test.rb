require "test_helper"
require_relative "base_order_controller_test"
require_relative "base_order_change_controller_test"
module Ddt
  module Webpos
    module Order
      class EatInHallOrdersControllerTest < TestCase::Controller::Webpos
        include Ddt::Webpos::Order::BaseOrderControllerTest
        include Ddt::Webpos::Order::BaseOrderChangeControllerTest
        setup do
          sign_in worker
          @order = example_eat_in_hall_order
        end

        def test_create
          table.reload.force_clear
          variant = create(:product, branch: branch).master
          assert_difference "branch.eat_in_hall_orders.count" do
            post :create, p(
              cart: {
                table_id: table.id,
                line_items_attributes: [{
                  itemable_type: "Ddt::Variant",
                  itemable_id: variant.id,
                  quantity: 1
                }]
              })
          end
          assert_response 200
        end

        def test_change_table
          post :change_table, p(id: @order.id, table_id: another_table.id)
          assert_response 200
        end

        def test_merge_table
          cart = OrderService::Cart::EatInHall.new(table: another_table, branch: branch, track_from: :FromWebpos)
          cart.add(variant)
          another_order = cart.place
          post :merge_table, p(id: @order.id, table_id: another_table.id)
          assert_response 200
        end

        def test_bind_reservation_order
          skip # TODO
        end

        def test_anti_settlement
          sign_in worker
          set_order_paid(worker)
          post :anti_settlement, p(id: @order.id)
          assert_response 200
          assert_not_equal json["pay_item_state"], "paid"
        end

        def test_update_guest_num
          sign_in waiter
          post :update_guest_num, p(id: @order.id, guest_num: 10)
          assert_response 200
          assert_equal json["guest_num"], 10
        end
      end
    end
  end
end
