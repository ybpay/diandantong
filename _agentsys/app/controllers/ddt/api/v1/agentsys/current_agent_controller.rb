module Ddt
  module Api
    module V1
      module Agentsys
        class CurrentAgentController < BaseController
          def show
            authorize! current_agent, to: :show?, with: Ddt::Agentsys::AgentPolicy
            render json: { data: agent_serialized(current_agent) }
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
