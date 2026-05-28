module Ddt
  module Agentsys
    class ShopPolicy < ActionPolicy::Base
      authorize :agent

      def index?
        true
      end

      def show?
        agent_managed?(record)
      end

      def create?
        agent.can_create_account?
      end

      def update?
        agent_managed?(record)
      end

      def renew?
        agent_managed?(record)
      end

      def suspend?
        agent_managed?(record)
      end

      def activate?
        agent_managed?(record)
      end

      def reset_password?
        agent_managed?(record)
      end

      private

      def agent_managed?(shop)
        agent.shops.where(id: shop.id).exists?
      end
    end
  end
end
