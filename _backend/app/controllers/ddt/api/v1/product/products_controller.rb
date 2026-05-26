module Ddt
  module Api
    module V1
      module Backend
        class ProductsController < Ddt::Api::V1::BaseController
          before_action :set_branch
          check_permission :branch, :product, base_permission_actions.merge({
            search: :show,
            [:batch_on_shelf, :batch_off_shelf] => :update,
            :batch_remove => :destroy
          })

          def index
            params[:q] = { s: "created_at desc" } if params[:q].blank?
            products = @branch.products.includes(:variants_including_master)
                          .ransack(params[:q]).result.distinct
            render_paginated(products)
          end

          def search
            products = @branch.products.ransack(params[:q]).result.distinct
            render_paginated(products)
          end

          def show
            product = @branch.products.includes(:variants, :categories).find(params[:id])
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

          def batch_on_shelf
            products = @branch.products.where(id: params[:product_ids])
            products.update_all(is_available: true)
            render_empty_success(message: "批量上架成功")
          end

          def batch_off_shelf
            products = @branch.products.where(id: params[:product_ids])
            products.update_all(is_available: false)
            render_empty_success(message: "批量下架成功")
          end

          def batch_remove
            ids = params[:product_ids]
            raise ActionController::ParameterMissing, "product_ids" if ids.blank?
            @branch.products.where(id: ids).destroy_all
            render_empty_success(message: "批量删除成功")
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
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
