module Ddt
  module Api
    module V1
      module Agentsys
        class SubAgentsController < BaseController
          def index
            authorize! current_agent, to: :manage_sub_agents?, with: Ddt::Agentsys::AgentPolicy
            sub_agents = Ddt::Agent.where(parent_agent: current_agent)
            render json: sub_agents.map { |a| sub_agent_json(a) }
          end

          def create
            authorize! current_agent, to: :create_sub_agent?, with: Ddt::Agentsys::AgentPolicy
            sub_agent = Ddt::Agent.new(sub_agent_params.merge(parent_agent: current_agent))
            if sub_agent.save
              render json: sub_agent_json(sub_agent), status: :created
            else
              render json: { errors: [{ status: 422, title: "创建失败", detail: sub_agent.errors.full_messages.join(", "), code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
            end
          end

          def update
            authorize! current_agent, to: :manage_sub_agents?, with: Ddt::Agentsys::AgentPolicy
            sub_agent = Ddt::Agent.where(parent_agent: current_agent).find(params[:id])
            attrs = sub_agent_update_params
            attrs[:discarded_at] = params[:status] == "inactive" ? Time.current : nil if params[:status]
            if sub_agent.update(attrs)
              render json: sub_agent_json(sub_agent)
            else
              render json: { errors: [{ status: 422, title: "更新失败", detail: sub_agent.errors.full_messages.join(", "), code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
            end
          end

          private

          def sub_agent_json(agent)
            {
              id: agent.id,
              name: agent.name,
              email: agent.email,
              phone: agent.phone,
              merchant_count: agent.shops.count,
              commission_rate: agent.discount.to_f,
              status: agent.discarded_at.nil? ? "active" : "inactive",
              created_at: agent.created_at.to_s
            }
          end

          def sub_agent_params
            params.permit(:name, :email, :password, :phone, :discount)
          end

          def sub_agent_update_params
            params.permit(:name, :phone, :discount)
          end
        end
      end
    end
  end
end
