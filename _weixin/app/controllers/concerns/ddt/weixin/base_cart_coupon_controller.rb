module Ddt
  module Weixin
    module BaseCartCouponController
      extend ActiveSupport::Concern
      def apply_coupon
        coupon_id = params[:coupon_id]
        @coupon = @current_user.coupons.find(coupon_id)
        @cart.set_coupon(@coupon)
        render :show
      end

      def clear_coupon
        @cart.clear_coupon
        render :show
      end
    end
  end
end
