require "test_helper"
module Ddt
  module Webpos
    class AccountsControllerTest < TestCase::Controller::Webpos
      def test_show
        sign_in worker
        get :show
        assert_response 200
        assert_equal json['id'], worker.id
      end

      def test_bosses_and_workers
        worker
        sign_in waiter
        get :bosses_and_workers
        assert_response 200
        assert_equal json.count, 2
      end

      def test_authorization_with_correct_password
        sign_in waiter
        post :authorization, auth_id: worker.id, password: "12345678"
        assert_response 200
        assert_equal json["ok"], true
      end

      def test_authorization_with_incorrect_password
        sign_in waiter
        post :authorization, auth_id: worker.id, password: "incorrect_password"
        assert_response 200
        assert_equal json["ok"], false
      end
    end
  end
end