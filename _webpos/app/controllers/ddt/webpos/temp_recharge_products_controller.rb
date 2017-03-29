module Ddt
  module Webpos
    class TempRechargeProductsController < Ddt::Webpos::BaseController
      def create
        @temp_recharge_product = @current_shop.temp_recharge_products.build(temp_recharge_product_params)
        if @temp_recharge_product.save
          render :show
        else
          render json: { error: @temp_recharge_product.errors.full_messages }, status: :bad_request
        end
      end

      private
      def temp_recharge_product_params
        params.require(:temp_recharge_product).permit(:price, :recharge_amount, :extra_credits)
      end
    end
  end
end