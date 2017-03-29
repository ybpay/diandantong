require "test_helper"
module Ddt
  module CommonApi
    module V1
      class ShopsControllerTest < TestCase::Controller::CommonApi
        def test_show
          get :show
          assert_response 200
          assert_equal shop.id, json["id"]
        end
      end
    end
  end
end
