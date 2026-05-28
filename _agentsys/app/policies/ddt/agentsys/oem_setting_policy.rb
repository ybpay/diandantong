module Ddt
  module Agentsys
    class OemSettingPolicy < ActionPolicy::Base
      authorize :agent

      def show?
        agent.is_oem?
      end

      def update?
        agent.is_oem?
      end
    end
  end
end
