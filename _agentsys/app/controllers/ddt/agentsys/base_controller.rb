# encoding: utf-8
module Ddt
  module Agentsys
    class BaseController < Ddt::BaseController

      before_action :authenticate_agentsys_agent!
      before_action :check_agent_expired

      layout 'ddt/layouts/agentsys/agent'


      def check_agent_expired
        if (current_agentsys_agent.expiration_time < Time.now rescue true)
          current_agentsys_agent.clear_balance if current_agentsys_agent.balance > 0
          sign_out current_agentsys_agent
          redirect_to new_agentsys_agent_session_path, alert: "账号已过期，请联系管理员"
        end
      end

    end
  end
end
