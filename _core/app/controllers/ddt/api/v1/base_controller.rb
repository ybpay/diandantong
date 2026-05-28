module Ddt
  module Api
    module V1
      class BaseController < ActionController::Base
        include Ddt::Api::Authenticatable
        include Ddt::Api::ErrorHandling
        include Ddt::Api::Pagination
        include Ddt::Api::Rendering
        include CheckFeature
        include CheckPermission
        include ActionPolicy::Controller

        authorize :account, through: :current_account
        authorize :shop, through: :current_shop
        authorize :branch, through: :current_branch

        rescue_from ActionPolicy::Unauthorized do |exception|
          raise Error::NoPermissionError, exception.message
        end

        protect_from_forgery with: :null_session
        skip_before_action :verify_authenticity_token

        before_action :set_shop_context
        before_action :set_branch_context
        before_action :check_shop_ban

        respond_to :json

        helper_method :current_account, :current_shop, :current_branch

        def current_account
          @current_account
        end

        def current_shop
          @current_shop
        end

        def current_branch
          @current_branch
        end

        def can?(*args)
          current_account&.can?(*args)
        end

        def authorize!(*args)
          current_account&.authorize!(*args)
        end
      end
    end
  end
end
