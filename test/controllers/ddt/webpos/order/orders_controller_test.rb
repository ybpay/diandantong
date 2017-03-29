require "test_helper"
module Ddt
  module Webpos
    module Order
      class OrdersControllerTest < TestCase::Controller::Webpos
        setup do
          sign_in waiter
        end

        def test_index
          set_order
          get :index, p
          assert_response 200
          assert_equal json.size, 1
        end

        def test_show
          set_order
          get :show, p(id: @order.id)
          assert_response 200
          assert_equal json["id"], @order.id
        end

        def test_batch_change_state
          skip # TODO
        end

        def test_pending_counts
          set_order
          get :pending_counts, p
          assert_response 200
          assert_equal json["Ddt::EatInHallOrder"], 1
        end

        private
        def set_order
          @order = example_eat_in_hall_order
        end
      end
    end
  end
end