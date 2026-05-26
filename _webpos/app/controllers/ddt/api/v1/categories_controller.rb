module Ddt
  module Api
    module V1
      module Webpos
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

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end
        end
      end
    end
  end
end
