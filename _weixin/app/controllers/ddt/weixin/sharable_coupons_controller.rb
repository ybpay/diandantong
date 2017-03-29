module Ddt
  class Weixin::SharableCouponsController < WeixinApplicationController
    respond_to :json
    before_action :set_sharable_coupon, only: [:show, :receive]
    def show
    end

    def receive
      if @sharable_coupon.can_receive_by?(@current_user)
        @sharable_coupon.receive_by(@current_user)
        render :json => { status: :ok}
      else
        render :json => { status: :fail, errors: @sharable_coupon.receive_errors.full_messages }
      end
    end

    private
    def set_sharable_coupon
      @sharable_coupon = @current_shop.sharable_coupons.find(params[:id])
    end
  end
end
