module Ddt
  module Weixin
    module Order
      module BaseOrderControllerTest
        extend ActiveSupport::Concern
        def test_show
          get :show, p(id: order.id)
          assert_response 200
        end

        def test_get_pay_online
          skip
        end

        def test_association_domains
          skip
        end

        def test_cancel
          skip
        end

        def test_confirm
          skip
        end

        def test_complete
          skip
        end

        def test_append_itemables
          if order.can_append_itemable?
            post :append_itemables, p(id: order.id, itemables: [{
                itemable_id: itemable.id,
                itemable_type: itemable.class.base_class.name,
                quantity: 1,
              }])
            assert_response 200
            assert_equal 2, order.reload.line_items.count
          else
            skip
          end
        end

        def test_get_permissions
          get :get_permissions, p(id: order.id)
          assert_response 200
        end

        private
        def set_cart_session(cart)
          session["#{branch.id}_#{cart.class.name.demodulize.underscore}"] = cart.to_session
        end
      end
    end
  end
end