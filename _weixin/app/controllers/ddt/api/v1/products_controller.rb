module Ddt
  module Api
    module V1
      module Weixin
        class ProductsController < Ddt::Api::V1::BaseController
          skip_before_action :authenticate_api_account!, only: [:index, :show]

          def index
            branch = find_branch
            products = branch.products.available.sale_on_today
                             .includes(:categories, :variants, :master)
                             .ransack(params[:q]).result
            render_paginated(products)
          end

          def show
            branch = find_branch
            product = branch.products.find(params[:id])
            render_resource(product)
          end

          private

          def find_branch
            current_shop&.branches&.find(params[:branch_id]) || Ddt::Branch.find(params[:branch_id])
          end
        end
      end
    end
  end
end
