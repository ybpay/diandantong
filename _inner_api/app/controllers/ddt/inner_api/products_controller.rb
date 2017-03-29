module Ddt
  module InnerApi
    class ProductsController < InnerApi::BaseController
      before_action :set_current_account
      before_action :set_branch
      def index
        @q = @branch.products.ransack(params[:q])
        @products = @q.result.paginate(page: params[:page], per_page: (params[:per_page] || 20))
      end

      private
      def set_branch
        @branch = @current_account.managed_branches.find(params[:branch_id])
      end
    end
  end
end
