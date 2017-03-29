require "test_helper"
module Ddt
  module CommonApi
    module V1
      class CategoriesControllerTest < TestCase::Controller::CommonApi

        def test_index
          category
          get :index, branch_id: branch.id
          assert_response 200
          assert_equal 1,json.size
        end

      end
    end
  end
end