module Ddt
  class Weixin::Cart::RechargeCartsController < WeixinApplicationController
    include Weixin::BaseCartController
    def add_recharge_product
      @cart.clear
      @recharge_product = @current_shop.recharge_products.find(params[:recharge_product_id])
      @cart.add(@recharge_product)
      render :show
    end
  end
end