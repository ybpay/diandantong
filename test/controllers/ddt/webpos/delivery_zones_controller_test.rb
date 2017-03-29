require "test_helper"
module Ddt
  module Webpos
    class DeliveryZonesControllerTest < TestCase::Controller::Webpos
      setup do
        sign_in waiter
      end
      def test_index
        delivery_zone
        get :index, p
        assert_response 200
        assert_equal json.size, 1
      end
    end
  end
end