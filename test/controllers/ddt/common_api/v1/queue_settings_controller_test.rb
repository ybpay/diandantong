require 'test_helper'
module Ddt
  module CommonApi
    module V1
      class QueueSettingsControllerTest < TestCase::Controller::CommonApi

        def setup
          queue_setting
        end

        def test_index
          get :index, branch_id: branch.id
          assert_response 200
          assert_equal 1, json.size
        end

      end
    end
  end
end
