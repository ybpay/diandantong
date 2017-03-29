require "test_helper"
module Ddt
  module CommonApi
    module V1
      module Order
        module BaseOrderChangeControllerTest
          extend ActiveSupport::Concern
          included do
            def test_append
              variant = create(:product, branch_id: branch.id, shop_id: shop.id).master
              post :append, p(id: @order.id, itemables: [{
                  itemable_id: variant.id,
                  itemable_type: "Ddt::Variant",
                  quantity: 1,
                }])
              assert_response 200
              assert_equal json["line_items"].size, 2
            end

            def test_active_line_items
              get :active_line_items, p(id: @order.id)
              assert_response 200
              assert_equal json.size, 1
            end

            def test_subtract
              line_item = @order.line_items.first
              post :subtract, p(id: @order.id, subtractables: [{
                  line_item_id: line_item.id,
                  quantity: 1,
                }])
              assert_response 200
              assert_equal json["line_items"].size, 0
            end
          end
        end
      end
    end
  end
end
