module Ddt
  class Weixin::User::SharableCouponsController < WeixinApplicationController
    respond_to :json
    before_action :set_sharable_coupon, only: [:show]
    def index
      @sharable_coupons = @current_user.sharable_coupons
    end

    def show
    end


    private

    def set_sharable_coupon
      @sharable_coupon = @current_user.sharable_coupons.find(params[:id])
    end
  end
end