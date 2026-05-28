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
        raise ActiveRecord::RecordNotFound unless payload["sub"]
        if Ddt::AgentJwtDenylist.where(jti: payload["jti"]).exists?
          render json: { errors: [{ status: 401, title: "Token已吊销", code: "TOKEN_REVOKED" }] }, status: :unauthorized
          return
        end
        @current_agent = Ddt::Agent.find(payload["sub"])
      rescue JWT::DecodeError, JWT::ExpiredSignature
        render json: { errors: [{ status: 401, title: "Token无效或已过期", code: "AUTH_FAILED" }] }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound
        render json: { errors: [{ status: 401, title: "用户不存在", code: "AUTH_FAILED" }] }, status: :unauthorized
      end

      def check_agent_expired
        exp = current_agent.expiration_time
        if exp.nil? || exp < Time.current
          render json: { errors: [{ status: 403, title: "账号已过期", code: "AGENT_EXPIRED" }] }, status: :forbidden
        end
      end
    end
  end
end
