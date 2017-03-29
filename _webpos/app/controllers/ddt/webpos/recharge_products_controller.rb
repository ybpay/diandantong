module Ddt
  module Webpos
    class RechargeProductsController < Ddt::Webpos::BaseController
      def index
        @recharge_products = @current_shop.recharge_products.support_of_branch(params[:branch_id])
        fresh_when(@recharge_products)
      end
    end
  end
end