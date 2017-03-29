require "test_helper"
module Ddt
  module Webpos
    class BranchesControllerTest < TestCase::Controller::Webpos
      def test_index
        sign_in worker
        get :index
        assert_response 200
        assert_equal json.length, 1
      end

      def test_show
        sign_in worker
        get :show, id: branch.id
        assert_response 200
      end

      def test_open_shift
        skip # TODO
      end

      def test_close_shift
        skip # TODO
      end

      def test_print_shift
        skip # TODO
      end
    end
  end
end