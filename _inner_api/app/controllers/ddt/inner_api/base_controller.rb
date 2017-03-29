module Ddt
  module InnerApi
    class NoInnerApiPermissionError < StandardError; end;
    class BaseController < ActionController::Base

      before_filter :api_authenticate

      rescue_from NoInnerApiPermissionError do |exception|
        respond_to do |format|
            format.json{ render json: {error: "无权访问" }, status: 401 }
            format.html{ render text: "无权访问", layout: false, status: 401 }
          end
      end

      protected
      def set_current_account
        @current_account = Ddt::Account.find(params[:current_account_id]) if params[:current_account_id].present?
        unless @current_account.present?
          raise NoInnerApiPermissionError.new
        end
      end

      def api_authenticate
        @api_key = Ddt::ApiKey.find_by_id(ApiAuth.access_id(request))
        # Rails.logger.info @api_key.access_token
        if @api_key.blank? || !ApiAuth.authentic?(request, @api_key.access_token)
          raise NoInnerApiPermissionError.new
        end
      end
    end
  end
end