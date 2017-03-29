
require 'test_helper'
module Ddt
  module CommonApi
    module V1
      class VariantPackagesControllerTest < TestCase::Controller::CommonApi

        def test_create
          post :create, p(variant_id: variant.id, weight: 0.5)
          assert_response 200
          assert_equal 1, branch.variant_packages.size
        end

        def test_update
          variant_package = branch.variant_packages.create!(variant_id: variant.id, weight: 1)
          post :update, p(id: variant_package.id, weight: 2)
          assert_response 200
          assert_equal 2 * variant_package.price, json['price'].to_f
        end

      end
    end
  end
end
