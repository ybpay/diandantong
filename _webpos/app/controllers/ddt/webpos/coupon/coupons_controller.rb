module Ddt
  module Webpos
    module Coupon
      class CouponsController < Webpos::BaseController
        include Ddt::Webpos::BaseCouponController
        check_permission :shop, :coupon, { [:search, :available] => :show, apply: :apply, [:find_by_code, :exchange_by_code] => :exchange}
        before_action :set_user, only: [:available, :apply]
        before_action :set_order, only: [:apply]
        before_action :set_coupon, only: [:apply]

        respond_to :json

        def search
          find_by_code
        end

        def available
          @coupons = @user.coupons.available
        end

        def apply
          if @order.present? && @coupon.can_apply?(@order)
            @coupon.apply(@order)
            @order.update!(update_pay_item: true)
            head :ok
          else
            render json: {errors: "该优惠券不能使用在该订单上"}, status: :bad_request
          end
        end

        private

        def set_user
          @user = @current_shop.base_users.find(params[:user_id])
        end

        def set_coupon
          @coupon = @user.coupons.available.find(params[:coupon_id])
        end

        def set_order
          @order = @user.active_orders.find(params[:order_id]) rescue nil
        end

      end
    end
  end
end
