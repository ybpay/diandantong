module Ddt
  module Api
    module V1
      module Agentsys
        class BaseController < ActionController::Base
          include Ddt::Api::AgentAuthenticatable
          include Ddt::Api::ErrorHandling
          include Ddt::Api::Pagination
          include Ddt::Api::Rendering
          include ActionPolicy::Controller

          authorize :agent, through: :current_agent

          rescue_from ActionPolicy::Unauthorized do |_exception|
            render json: { errors: [{ status: 403, title: "无权限", code: "FORBIDDEN" }] }, status: :forbidden
          end

          protect_from_forgery with: :null_session
          skip_before_action :verify_authenticity_token

          before_action :check_agent_expired

          respond_to :json

          helper_method :current_agent
        end
      end
    end
  end
end
