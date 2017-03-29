require "test_helper"
module Ddt
  module Weixin
    class ProductsControllerTest < TestCase::Controller::Weixin
      def test_index
        product
        get :index, p
        assert_response 200
        assert_equal json.size, 1
      end

      def test_show
        get :show, p(id: product.id)
        assert_response 200
        assert_equal json["id"], product.id
      end
    end
  end
end