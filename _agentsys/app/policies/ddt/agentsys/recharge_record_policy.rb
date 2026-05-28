module Ddt
  module Agentsys
    class RechargeRecordPolicy < ActionPolicy::Base
      authorize :agent

      def index?
        true
      end

      def show?
        record.agent_id == agent.id
      end

      def create?
        agent.shops.where(id: record.shop_id).exists?
      end
    end
  end
end
