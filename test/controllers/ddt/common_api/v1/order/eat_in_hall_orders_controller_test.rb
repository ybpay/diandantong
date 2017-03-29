require 'test_helper'
require_relative './base_order_controller_test'
require_relative './base_order_change_controller_test'

module Ddt
  module CommonApi
    module V1
      module Order
        class EatInHallOrdersControllerTest < TestCase::Controller::CommonApi
          include V1::Order::BaseOrderControllerTest
          include V1::Order::BaseOrderChangeControllerTest

          def setup
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
                },
                branch_id: branch.id,
                track_from: 'FromWebpos'
              )
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

        end
      end
    end
  end
end
