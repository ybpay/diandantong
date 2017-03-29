require "test_helper"
module Ddt
  module CommonApi
    module V1
      class TableZonesControllerTest < TestCase::Controller::CommonApi

        def setup
          table_zone
        end

        def test_index
          get :index, params
          assert_response 200
          assert_equal 1, json.size
        end

        def test_with_tables
          get :with_tables, params
          assert_response 200
          assert_equal 2, json[0]['tables'].size
        end

        def test_with_reservation_time_points
          get :with_reservation_time_points, params
          assert_response 200
          assert_equal 1, json[0]["reservation_time_points"].size
        end

        def params
          {branch_id: branch.id}
        end

      end
    end
  end
end
