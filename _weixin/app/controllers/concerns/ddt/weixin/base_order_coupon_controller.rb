module Ddt
  module Weixin
    module BaseOrderCouponController
      extend ActiveSupport::Concern
      def apply_coupon
        coupon_id = params[:coupon_id]
        @coupon = @current_user.coupons.find(coupon_id)
        @order.apply_coupon(@coupon)
        render :show
      end

      def clear_coupon
        @order.rollback_coupon
        render :show
      end
    end
  end
end
