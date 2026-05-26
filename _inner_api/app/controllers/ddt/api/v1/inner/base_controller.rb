module Ddt
  module Api
    module V1
      module Inner
        class BaseController < ActionController::Base
          include Ddt::Api::ErrorHandling

          protect_from_forgery with: :null_session
          skip_before_action :verify_authenticity_token

          respond_to :json

          before_action :api_authenticate

          private

          def api_authenticate
            @api_key = Ddt::ApiKey.find_by_id(ApiAuth.access_id(request))
            if @api_key.blank? || !ApiAuth.authentic?(request, @api_key.access_token)
              raise Ddt::Api::AuthenticationError, "无效的API密钥"
            end
          end

          def current_account
            @current_account ||= Ddt::Account.find(params[:current_account_id]) if params[:current_account_id].present?
          end
        end
      end
    end
  end
end
