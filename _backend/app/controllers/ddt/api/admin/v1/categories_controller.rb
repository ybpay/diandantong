module Ddt
  module Api
    module Admin
      module V1
        class CategoriesController < BaseController
          before_action :set_category, only: [:show, :update, :destroy]

          def index
            categories = Ddt::Category.joins(:branch).where(branches: { shop_id: current_shop.id }).ransack(params[:q]).result
            render_paginated(categories)
          end

          def show
            render_resource(@category)
          end

          def create
            branch = current_shop.branches.find(params[:branch_id]) if params[:branch_id]
            category = (branch || current_shop.branches.first).categories.build(category_params)
            if category.save
              render_resource_created(category)
            else
              render_errors(category.errors)
            end
          end

          def update
            if @category.update(category_params)
              render_resource(@category)
            else
              render_errors(@category.errors)
            end
          end

          def destroy
            @category.destroy
            render_empty_success(message: "分类已删除")
          end

          private

          def set_category
            @category = Ddt::Category.joins(:branch).where(branches: { shop_id: current_shop.id }).find(params[:id])
          end

          def category_params
            params.require(:category).permit(:name, :parent_id, :position, :is_active)
          end
        end
      end
    end
  end
end
