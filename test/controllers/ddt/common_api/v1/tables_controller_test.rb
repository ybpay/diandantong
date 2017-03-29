require "test_helper"
module Ddt
  module CommonApi
    module V1
      class TablesControllerTest < TestCase::Controller::CommonApi

        def setup
          table
        end

        def test_index
          get :index, branch_id: branch.id
          assert_response 200
        end

        def test_show
          get :show, branch_id: branch.id, id: table.id
          assert_response 200
        end

        def test_open
          get :open, branch_id: branch.id, id: table.id
          assert_response 200
          assert_equal 'opened', json['workflow_state']
        end

        def test_clear
          table.open
          get :clear, branch_id: branch.id, id: table.id
          assert_response 200
          assert_equal 'idle', json['workflow_state']
        end

        def test_check_out
          @order = example_eat_in_hall_order
          post :check_out, branch_id: branch.id, id: @order.table.id
          assert_response 200
          assert_equal 'check_outing', @order.table.reload.workflow_state
        end

        def test_cancel_check_out
          @order = example_eat_in_hall_order
          @order.table.check_out!
          post :cancel_check_out, branch_id: branch.id, id: @order.table.id
          assert_response 200
          assert_equal 'ordered', @order.table.reload.workflow_state
        end

        def params
          {branch_id: branch.id}
        end

      end
    end
  end
end
