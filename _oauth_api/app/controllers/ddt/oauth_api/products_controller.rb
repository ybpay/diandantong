module Ddt
  module OauthApi
    class ProductsController < OauthApi::BaseController
      before_action :set_branch
      def index
        @products = @branch.products.includes(:master, :categories, :option_types, variants: :option_values)
      end

      private
      def set_branch
        @branch = @current_shop.branches.find(params[:branch_id])
      end
    end
  end
end
