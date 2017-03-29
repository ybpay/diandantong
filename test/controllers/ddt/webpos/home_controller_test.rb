require "test_helper"
module Ddt
  module Webpos
    class HomeControllerTest < TestCase::Controller::Webpos
      def test_index
        get :index, format: :html
        assert_response :success
      end
    end
  end
end