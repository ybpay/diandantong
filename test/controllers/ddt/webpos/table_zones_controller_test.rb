require "test_helper"
module Ddt
  module Webpos
    class TableZonesControllerTest < TestCase::Controller::Webpos
      setup do
        sign_in waiter
        table_zone
      end

      def test_index
        get :index, p
        assert_response 200
        assert_equal json.size, 1
      end

      def test_with_reservation_time_points
        skip # TODO
      end
    end
  end
end