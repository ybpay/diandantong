require "test_helper"
module Ddt
  module CommonApi
    module V1
      class CombosControllerTest < TestCase::Controller::CommonApi

        def setup
          combo
        end

        def test_index
          get :index, p(order_type: 'eat_in_hall')
          assert_response 200
          assert_equal combo.id, json[0]["id"]
        end

        def test_add_combo_package
          items = combo.combo_items.map do |combo_item|
            {
              combo_item_id: combo_item.id,
              variant_id: combo_item.variants[0].id,
              quantity: 1
            }
          end
          assert_difference "combo.combo_packages.count" do
            post :add_combo_package, p(id: combo.id, combo_package: items )
          end
          assert_response 200
        end

      end
    end
  end
end
