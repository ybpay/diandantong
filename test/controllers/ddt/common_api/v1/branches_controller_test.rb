require "test_helper"
module Ddt
  module CommonApi
    module V1
      class BranchesControllerTest < TestCase::Controller::CommonApi
        def test_show
          get :show , id: branch.id
          assert_response 200
          assert_equal branch.id, json["id"]
        end

        def test_index
          get :index
          assert_response :success
          assert_equal 1, json.size
        end

        def test_cache_versions
          get :cache_versions, id: branch.id
          assert_response 200
          refute_nil json["categories"]
          refute_nil json["products"]
          refute_nil json["combos"]
          refute_nil json["table_zones"]
        end

        def test_update_cs_data
          post :update_cs_data, id: branch.id, start_at: '2016-04-00 00:00:00', end_at: '2016-06-15 23:59:59'
          assert_response 200
        end

        def test_update_cs_data_bad_params
          post :update_cs_data, id: branch.id, start_at: '2016-04-00 ', end_at: '2016-06-15'
          assert_response 400
        end

      end
    end
  end
end
