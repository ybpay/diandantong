module Ddt
  module Backend
    class BaseAdminController < Backend::BaseController
      before_action :check_admin_auth

      private
      def check_admin_auth
        raise ErrorNoAuthException.new('非点单通公司管理人员无权进行此操作') unless current_account.is_admin?
      end
    end
  end
end
