module Ddt
  module Api
    module V1
      module Webpos
        class TablesController < Ddt::Api::V1::BaseController
          before_action :set_branch

          def index
            tables = @branch.tables.includes(:table_zone).ransack(params[:q]).result
            render json: { data: tables.map(&:as_api_json) }
          end

          def show
            table = @branch.tables.find(params[:id])
            render_resource(table)
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
