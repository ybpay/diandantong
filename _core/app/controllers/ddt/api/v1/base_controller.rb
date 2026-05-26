module Ddt
  module Api
    module V1
      class BaseController < ActionController::Base
        include Ddt::Api::Authenticatable
        include Ddt::Api::ErrorHandling
        include Ddt::Api::Pagination
        include CheckFeature
        include CheckPermission

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

        private

        def render_resource(resource, serializer: nil, status: :ok)
          json = if serializer
                   serializer.new(resource).as_json
                 elsif resource.respond_to?(:as_api_json)
                   resource.as_api_json
                 else
                   resource.as_json
                 end
          render json: { data: json }, status: status
        end

        def render_resource_created(resource, serializer: nil)
          render_resource(resource, serializer: serializer, status: :created)
        end

        def render_empty_success(message: "操作成功")
          render json: { data: { message: message } }, status: :ok
        end

        def render_errors(errors, status: :unprocessable_entity)
          error_objects = errors.map do |attr, msg|
            {
              status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status],
              source: { pointer: "/data/attributes/#{attr}" },
              detail: msg
            }
          end
          render json: { errors: error_objects }, status: status
        end
      end
    end
  end
end
