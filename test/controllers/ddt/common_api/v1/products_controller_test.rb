require "test_helper"
module Ddt
  module CommonApi
    module V1
      class ProductsControllerTest < TestCase::Controller::CommonApi

        def test_index
          product
          get :index ,branch_id: branch.id
          assert_response :success
          assert_equal product.id , json[0]["id"]
        end

      end
    end
  end
end