module Ddt
  module InnerApi
    class AgentsController < InnerApi::BaseController
      before_action :set_agent, only: [:show]
      def index
        if params[:q].present? && params[:q].any?{|key, value| value.present?}
          @q = Ddt::Agent.where(agent_no: nil).ransack(params[:q])
          @agents = @q.result.paginate(page: params[:page], per_page: 5)
        else
          @agents = []
        end
      end

      def show
      end

      private
      def set_agent
        @agent = Ddt::Agent.find(params[:id])
      end
    end
  end
end