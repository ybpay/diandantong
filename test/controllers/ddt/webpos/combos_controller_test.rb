require "test_helper"
module Ddt
  module Webpos
    class CombosControllerTest < TestCase::Controller::Webpos
      setup do
        sign_in waiter
      end
      def test_index
        combo = create(:combo_with_items, branch_id: branch.id, shop_id: shop.id)
        get :index, p
        assert_response 200
        assert_equal json.size, 1
      end

      def test_add_combo_package
        combo = create(:combo_with_items, branch_id: branch.id, shop_id: shop.id)
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
