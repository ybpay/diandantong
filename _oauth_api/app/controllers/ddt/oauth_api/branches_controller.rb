module Ddt
  module OauthApi
    class BranchesController < OauthApi::BaseController
      def index
        @branches = @current_shop.branches
        render json: @branches.map{ |branch| branch.as_json(only: [:id, :name])}
      end
    end
  end
end
