module Ddt
  module Api
    module V1
      module Webpos
        class ProductsController < Ddt::Api::V1::BaseController
          before_action :set_branch
          check_permission :branch, :product, base_permission_actions

          def index
            products = @branch
                         .products
                         .available
                         .sale_on_today
                         .includes(:categories, :variants, :master)
                         .ransack(params[:q]).result

            if params[:no_paginate]
              render json: { data: products.map(&:as_api_json) }
            else
              render_paginated(products)
            end
          end

          def show
            product = @branch.products.includes(:variants, :master, :categories).find(params[:id])
            render_resource(product)
          end

          def create
            product = @branch.products.build(product_params)
            if product.save
              render_resource_created(product)
            else
              render_errors(product.errors)
            end
          end

          def update
            product = @branch.products.find(params[:id])
            if product.update(product_params)
              render_resource(product)
            else
              render_errors(product.errors)
            end
          end

          def destroy
            product = @branch.products.find(params[:id])
            product.destroy
            render_empty_success(message: "产品已删除")
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def product_params
            params.require(:product).permit(
              :name, :description, :price, :is_available,
              :category_id, :position,
              variants_attributes: [:id, :price, :is_master, :sku, :_destroy]
            )
          end
        end
      end
    end
  end
end
