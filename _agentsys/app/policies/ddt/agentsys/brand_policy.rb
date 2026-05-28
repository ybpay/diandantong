module Ddt
  module Agentsys
    class BrandPolicy < ActionPolicy::Base
      authorize :agent

      def index?
        agent.is_oem?
      end

      def show?
        agent.is_oem?
      end

      def create?
        agent.is_oem?
      end

      def update?
        agent.is_oem?
      end
    end
  end
end
