require "test_helper"
module Ddt
  module Backend
    class ShopsControllerTest < TestCase::Controller::Backend
      def test_index
        get :index
        assert_response 302
      end
    end
  end
end