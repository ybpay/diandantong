module Ddt
  module Api
    module Admin
      module V1
        class RechargeProductsController < BaseController
          before_action :set_recharge_product, only: [:show, :update, :destroy]

          def index
            recharge_products = current_shop.recharge_products.ransack(params[:q]).result
            render_paginated(recharge_products)
          end

          def show
            render_resource(@recharge_product)
          end

          def create
            recharge_product = current_shop.recharge_products.build(recharge_product_params)
            if recharge_product.save
              render_resource_created(recharge_product)
            else
              render_errors(recharge_product.errors)
            end
          end

          def update
            if @recharge_product.update(recharge_product_params)
              render_resource(@recharge_product)
            else
              render_errors(@recharge_product.errors)
            end
          end

          def destroy
            @recharge_product.destroy
            render_empty_success(message: "充值产品已删除")
          end

          private

          def set_recharge_product
            @recharge_product = current_shop.recharge_products.find(params[:id])
          end

          def recharge_product_params
            params.require(:recharge_product).permit(
              :name, :price, :recharge_amount, :extra_credits, :first_recharge_available_amount
            )
          end
        end
      end
    end
  end
end
