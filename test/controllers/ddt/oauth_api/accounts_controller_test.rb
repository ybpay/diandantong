require "test_helper"
module Ddt
  module OauthApi
    class AccountsControllerTest < TestCase::Controller::OauthApi
      let(:app){ create :application}
      def test_show
        get :show
        assert_response 200
        assert json["id"], boss.id
      end
    end
  end
end