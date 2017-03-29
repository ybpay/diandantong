module Ddt
  module Backend
    class RechargeProductsController < Ddt::Backend::BaseController
      check_permission :shop, :recharge_product
      before_action :set_recharge_product, only: [:show, :edit, :update, :destroy, :change_position]

      def index
        @recharge_products = @current_shop.recharge_products
      end

      def show
      end

      def new
        @recharge_product = @current_shop.recharge_products.new
      end

      def create
        @recharge_product = @current_shop.recharge_products.build(recharge_product_params)
        if @recharge_product.save
          render :reset
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @recharge_product.update(recharge_product_params)
          render :reset
        else
          render :edit
        end
      end

      def destroy
        @recharge_product.destroy
        render :reset
      end

      def change_position
        @recharge_product.change_position(params[:position])
        render :reset
      end

      private
      def set_recharge_product
        @recharge_product = @current_shop.recharge_products.find(params[:id])
      end

      def recharge_product_params
        params.require(:recharge_product).permit(:name, :price, :recharge_amount, :extra_credits, :first_recharge_available_amount)
      end
    end
  end
end