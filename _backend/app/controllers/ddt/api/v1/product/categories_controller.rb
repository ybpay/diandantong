module Ddt
  module Api
    module V1
      module Backend
        class CategoriesController < Ddt::Api::V1::BaseController
          before_action :set_branch

          def index
            categories = @branch.categories.ransack(params[:q]).result.order(:position)
            render json: { data: categories.map(&:as_api_json) }
          end

          def show
            category = @branch.categories.find(params[:id])
            render_resource(category)
          end

          def create
            category = @branch.categories.build(category_params)
            if category.save
              render_resource_created(category)
            else
              render_errors(category.errors)
            end
          end

          def update
            category = @branch.categories.find(params[:id])
            if category.update(category_params)
              render_resource(category)
            else
              render_errors(category.errors)
            end
          end

          def destroy
            category = @branch.categories.find(params[:id])
            category.destroy
            render_empty_success(message: "分类已删除")
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def category_params
            params.require(:category).permit(:name, :position, :parent_id, :is_active)
          end
        end
      end
    end
  end
end
