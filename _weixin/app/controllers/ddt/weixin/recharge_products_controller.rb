module Ddt
  class Weixin::RechargeProductsController < WeixinApplicationController

    def index
      @recharge_products = @current_shop.recharge_products.support_all_branch
      if stale?(@recharge_products)
        render :json => @recharge_products
      end
    end

  end
end
