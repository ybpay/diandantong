require "test_helper"
module Ddt
  module Weixin
    class CategoriesControllerTest < TestCase::Controller::Weixin
      def test_index
        category
        product.categories << category
        get :index, p(support_type: :delivery)
        assert_response 200
        assert_equal json.size, 1
      end
    end
  end
end