module Ddt
  module Api
    module AgentAuthenticatable
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_agent!
      end

      private

      def authenticate_agent!
        if jwt_token.present?
          authenticate_agent_via_jwt!
        else
          render json: { errors: [{ status: 401, title: "认证失败", code: "AUTH_FAILED" }] }, status: :unauthorized
        end
      end

      def current_agent
        @current_agent
      end

      def jwt_token
        request.headers["Authorization"]&.sub(/^Bearer\s+/i, "")
      end

      def authenticate_agent_via_jwt!
        payload = Warden::JWTAuth::TokenDecoder.new.call(jwt_token)
        @current_agent = Ddt::Agent.find(payload["sub"])
      rescue StandardError
        render json: { errors: [{ status: 401, title: "认证失败", code: "AUTH_FAILED" }] }, status: :unauthorized
      end

      def check_agent_expired
        if current_agent.expiration_time < Time.current
          render json: { errors: [{ status: 403, title: "账号已过期", code: "AGENT_EXPIRED" }] }, status: :forbidden
        end
      end
    end
  end
end
