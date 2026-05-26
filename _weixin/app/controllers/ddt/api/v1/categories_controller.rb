module Ddt
  module Api
    module V1
      module Weixin
        class CategoriesController < Ddt::Api::V1::BaseController
          skip_before_action :authenticate_api_account!, only: [:index]

          def index
            branch = Ddt::Branch.find(params[:branch_id])
            categories = branch.categories.order(:position)
            render json: { data: categories.map(&:as_api_json) }
          end
        end
      end
    end
  end
end
