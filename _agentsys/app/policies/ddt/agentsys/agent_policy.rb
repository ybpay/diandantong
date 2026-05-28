module Ddt
  module Agentsys
    class AgentPolicy < ActionPolicy::Base
      authorize :agent

      def show?
        agent == user
      end

      def update?
        agent == user
      end

      def create_sub_agent?
        agent == user
      end

      def manage_sub_agents?
        agent == user
      end
    end
  end
end
