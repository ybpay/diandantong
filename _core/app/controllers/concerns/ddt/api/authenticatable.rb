module Ddt
  module Api
    module Authenticatable
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_api_account!
      end

      private

      def authenticate_api_account!
        if jwt_token.present?
          authenticate_via_jwt!
        elsif legacy_token.present?
          authenticate_via_legacy_token!
        elsif doorkeeper_token.present?
          authenticate_via_oauth!
        else
          raise Ddt::Api::AuthenticationError, "缺少认证信息"
        end
      end

      def current_account
        @current_account
      end

      def current_shop
        @current_shop ||= begin
          if current_account&.is_admin?
            slug = params[:shop_slug] || params[:shop_id]
            Ddt::Shop.find(slug) if slug.present?
          else
            current_account&.shop
          end
        end
      end

      def current_branch
        @current_branch ||= begin
          key = params[:branch_id]
          if key.present? && current_account
            current_account.managed_branches.find_by(id: key)
          end
        end
      end

      def jwt_token
        request.headers["Authorization"]&.sub(/^Bearer\s+/i, "")
      end

      def legacy_token
        {
          login_id: request.headers["X-Account-Login-Id"] || params[:login_id],
          token: request.headers["X-Account-Authentication-Token"] || params[:authentication_token]
        }.select { |_, v| v.present? }
      end

      def doorkeeper_token
        return nil unless defined?(Doorkeeper)
        request.env["doorkeeper.token"]
      end

      def authenticate_via_jwt!
        return unless defined?(Warden::JWTAuth)

        payload = Warden::JWTAuth::TokenDecoder.new.call(jwt_token)
        account = Account.find(payload["sub"])
        @current_account = account
      rescue StandardError
        raise Ddt::Api::AuthenticationError, "JWT认证失败"
      end

      def authenticate_via_legacy_token!
        login_id = request.headers["X-Account-Login-Id"] || params[:login_id]
        token = request.headers["X-Account-Authentication-Token"] || params[:authentication_token]
        return if login_id.blank? || token.blank?

        account = Account.where(
          ["lower(login_id) = :value OR lower(email) = :value", { value: login_id.downcase }]
        ).first

        if account && Devise.secure_compare(account.authentication_token, token)
          if account.authentication_token_expired?
            raise Ddt::Api::TokenExpiredError, "Token已过期"
          end
          @current_account = account
        else
          raise Ddt::Api::AuthenticationError, "Token认证失败"
        end
      end

      def authenticate_via_oauth!
        @current_account = Account.find(doorkeeper_token.resource_owner_id)
      rescue StandardError
        raise Ddt::Api::AuthenticationError, "OAuth认证失败"
      end

      def set_shop_context
        slug = params[:shop_slug] || params[:shop_id] || (controller_name == "shops" ? params[:id] : nil)
        @current_shop = Ddt::Shop.find(slug) if slug.present?
        if @current_shop.nil? && current_account && !current_account.is_admin?
          @current_shop = current_account.shop
        end
        Ddt::Shop.current = @current_shop
      end

      def set_branch_context
        key = params[:branch_id] || (controller_name == "branches" ? params[:id] : nil)
        if key.present? && current_account
          @current_branch = current_account.managed_branches.find_by(id: key)
          raise Ddt::Api::ForbiddenError, "无权访问该门店" if @current_branch.nil?
        end
      end

      def check_shop_ban
        return if current_account&.is_admin?
        return unless @current_shop&.is_ban?

        raise Ddt::Api::ForbiddenError, "系统供应商已暂停该门店服务"
      end
    end
  end
end
