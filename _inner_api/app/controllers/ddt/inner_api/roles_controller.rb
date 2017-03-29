module Ddt
  module InnerApi
    class RolesController < InnerApi::BaseController
      before_action :set_current_account
      before_action :set_role, only: [:show]

      def index
        @roles = @current_account.roles
      end

    end
  end
end