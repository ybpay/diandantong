module Ddt
  module InnerApi
    class BranchesController < InnerApi::BaseController
      before_action :set_current_account
      before_action :set_branch, only: [:show]
      def index
        @q = @current_account.managed_branches.ransack(params[:q])
        @branches = @q.result.paginate(page: params[:page], per_page: (params[:per_page] || 5))
      end

      def show
      end

      private
      def set_branch
        @branch = @current_account.managed_branches.find(params[:id])
      end

    end
  end
end
