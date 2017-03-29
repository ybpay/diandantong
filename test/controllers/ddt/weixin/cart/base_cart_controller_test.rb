module Ddt
  module Weixin
    module Cart
      module BaseCartControllerTest
        extend ActiveSupport::Concern
        included do
          def test_show
            get :show, p
            assert_response 200
            assert_equal 0, json["line_items"].size
          end

          def test_add_itemable
            post :add_itemable, p(itemable_type: itemable.class.base_class.name, itemable_id: itemable.id, note: "note")
            assert_response 200
            assert_equal 1, json["line_items"].size
          end

          def test_remove_itemable
            cart.add(itemable)
            set_cart_session(cart)
            post :remove_itemable, p(itemable_type: itemable.class.base_class.name, itemable_id: itemable.id)
            assert_response 200
            assert_equal 0, json["line_items"].size
          end

          def test_clear
            cart.add(itemable)
            set_cart_session(cart)
            post :clear, p
            assert_response 200
            assert_equal 0, json["line_items"].size
          end

          def test_update_cart
            items = [{ itemable_type: itemable.class.base_class.name, itemable_id: itemable.id, quantity: 1}]
            post :update_cart, p(cart: { line_items_attributes: items })
            assert_response 200
            assert_equal 1, json["line_items"].size
          end

          def test_add_combo_package
            combo = create :combo_with_items, items_count: 1, branch_id: branch.id, shop_id: shop.id
            items = combo.combo_items.map do |combo_item|
              {
                combo_item_id: combo_item.id,
                variant_id: combo_item.variants.first.id,
                quantity: 1,
              }
            end
            post :add_combo_package, p(combo_package: { combo_id: combo.id, items: items })
            assert_response 200
            assert_equal 1, json["line_items"].size
          end

          private
          def set_cart_session(cart)
            session["#{branch.id}_#{cart.class.name.demodulize.underscore}"] = cart.to_session
          end
        end
      end
    end
  end
end