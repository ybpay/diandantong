require "test_helper"
module Ddt
  module Webpos
    class AbilitiesControllerTest < TestCase::Controller::Webpos
      def test_show_with_login
        sign_in boss
        get :show
        assert_response 200
      end

      def test_show_without_login
        get :show
        assert_response 401
      end
    end
  end
end