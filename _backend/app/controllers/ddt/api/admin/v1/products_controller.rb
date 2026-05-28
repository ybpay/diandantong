module Ddt
  module Api
    module Admin
      module V1
        class ProductsController < BaseController
          before_action :set_product, only: [:show, :update, :destroy]

          def index
            products = current_shop.products.includes(:variants_including_master).ransack(params[:q]).result.distinct
            render_paginated(products)
          end

          def show
            render_resource(@product, serializer: ->(p) { p.as_json(include: [:variants, :categories]) })
          end

          def create
            branch = current_shop.branches.find(params[:branch_id]) if params[:branch_id]
            product = (branch || current_shop.branches.first).products.build(product_params)
            if product.save
              render_resource_created(product)
            else
              render_errors(product.errors)
            end
          end

          def update
            if @product.update(product_params)
              render_resource(@product)
            else
              render_errors(@product.errors)
            end
          end

          def destroy
            @product.destroy
            render_empty_success(message: "产品已删除")
          end

          private

          def set_product
            @product = Ddt::Product.joins(:branch).where(branches: { shop_id: current_shop.id }).find(params[:id])
          end

          def product_params
            params.require(:product).permit(
              :name, :description, :price, :is_available, :category_id, :position,
              variants_attributes: [:id, :price, :is_master, :sku, :cost_price, :_destroy]
            )
          end
        end
      end
    end
  end
end
