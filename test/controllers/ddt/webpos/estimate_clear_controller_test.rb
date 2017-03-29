require "test_helper"
module Ddt
  module Webpos
    class EstimateClearControllerTest < TestCase::Controller::Webpos
      setup do
        sign_in worker
      end

      def test_index
        variant.add_estimate_clear
        get :index, p
        assert_response 200
      end

      def test_add
        post :add, p(variant_id: variant.id)
        assert_response 200
        assert variant.reload.estimate_clear?
      end

      def test_remove
        variant.add_estimate_clear
        post :remove, p(variant_id: variant.id)
        assert_response 200
        assert !variant.reload.estimate_clear?
      end

      def test_clear
        variant.add_estimate_clear
        post :clear, p
        assert_response 200
        assert !variant.reload.estimate_clear?
      end

      def test_add_reciprocal
        post :add_reciprocal, p(variant_id: variant.id, quantity: 2)
        assert_response 200
        assert variant.reload.estimate_clear_reciprocal?
      end

      def test_remove_reciprocal
        post :remove_reciprocal, p(variant_id: variant.id)
        assert_response 200
        assert !variant.reload.estimate_clear_reciprocal?
      end
    end
  end
end
