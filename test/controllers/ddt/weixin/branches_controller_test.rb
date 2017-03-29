require "test_helper"
module Ddt
  module Weixin
    class BranchesControllerTest < TestCase::Controller::Weixin
      def test_index
        get :index, p
        assert_response 200
        assert_equal json.size, 1
      end

      def test_show
        get :show, p(id: branch.id)
        assert_response 200
        assert_equal json["id"], branch.id
      end
    end
  end
end