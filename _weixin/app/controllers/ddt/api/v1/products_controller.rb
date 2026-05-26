module Ddt
  module Api
    module V1
      module Weixin
        class ProductsController < Ddt::Api::V1::BaseController
          skip_before_action :authenticate_api_account!, only: [:index, :show]

          def index
            branch = Ddt::Branch.find(params[:branch_id])
            products = branch.products.available.sale_on_today
                             .includes(:categories, :variants, :master)
                             .ransack(params[:q]).result
            render_paginated(products)
          end

          def show
            branch = Ddt::Branch.find(params[:branch_id])
            product = branch.products.find(params[:id])
            render_resource(product)
          end
        end
      end
    end
  end
end
