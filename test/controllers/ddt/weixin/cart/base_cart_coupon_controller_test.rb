module Ddt
  module Weixin
    module Cart
      module BaseCartCouponControllerTest
        extend ActiveSupport::Concern
        def test_apply_coupon
          cart.add(itemable)
          set_cart_session(cart)
          post :apply_coupon, p(coupon_id: coupon.id)
          assert_response 200
          assert json["coupon"].present?
          assert_equal 1, json["adjustments"].size
        end

        def test_clear_coupon
          cart.add(itemable)
          cart.set_coupon(coupon)
          set_cart_session(cart)
          post :clear_coupon, p
          assert_response 200
          assert_equal 0, json["adjustments"].size
        end

        private
        def set_cart_session(cart)
          session["#{branch.id}_#{cart.class.name.demodulize.underscore}"] = cart.to_session
        end
      end
    end
  end
end
