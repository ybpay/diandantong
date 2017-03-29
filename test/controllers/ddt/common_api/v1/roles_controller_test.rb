require 'test_helper'
module Ddt
  module CommonApi
    module V1
      class RolesControllerTest < TestCase::Controller::CommonApi

        def test_index
          get :index
          assert_response 200
        end

      end
    end
  end
end
