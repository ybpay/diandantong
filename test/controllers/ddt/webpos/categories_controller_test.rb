require "test_helper"
module Ddt
  module Webpos
    class CategoriesControllerTest < TestCase::Controller::Webpos
      setup do
        sign_in waiter
      end
      def test_index
        category = create(:category, branch_id: branch.id, shop_id: shop.id)
        get :index, p
        assert_response 200
        assert_equal json.size, 1
      end
    end
  end
end