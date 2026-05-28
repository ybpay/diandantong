module Ddt
  module Api
    module V1
      module Agentsys
        class SessionsController < ActionController::Base
          include Ddt::Api::ErrorHandling
          include Ddt::Api::Rendering

          protect_from_forgery with: :null_session
          skip_before_action :verify_authenticity_token
          respond_to :json

          def create
            agent = Ddt::Agent.find_by(email: params[:email]&.downcase)
            if agent&.valid_password?(params[:password])
              if agent.expiration_time < Time.current
                render json: { errors: [{ status: 403, title: "账号已过期，请联系管理员", code: "AGENT_EXPIRED" }] }, status: :forbidden
                return
              end
              token = Warden::JWTAuth::UserEncoder.new.call(agent, :agent, nil).first
              render json: {
                token: token,
                user: agent_serialized(agent)
              }
            else
              render json: { errors: [{ status: 401, title: "邮箱或密码错误", code: "AUTH_FAILED" }] }, status: :unauthorized
            end
          end

          def destroy
            render json: { data: { message: "已退出登录" } }
          end

          private

          def agent_serialized(agent)
            {
              id: agent.id,
              name: agent.name,
              email: agent.email,
              phone: agent.phone,
              role: agent.agent_type,
              avatar: agent.logo&.url
            }
          end
        end
      end
    end
  end
end
