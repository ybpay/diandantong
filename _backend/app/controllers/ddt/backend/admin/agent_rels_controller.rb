module Ddt
  module Backend
    class Admin::AgentRelsController < Backend::BaseAdminController

      before_action :set_agent_zone
      before_action :set_agent_rel, only: [:edit, :update]

      def index
        @agent_rels = @agent_zone.agent_rels.includes(:agent)
      end

      def edit
      end

      def update
        @agent_rel.update(agent_rel_params)
        redirect_to [:backend, @agent_zone, :agent_rels], notice: '更新成功'
      end

      private
        def set_agent_zone
          @agent_zone = Ddt::AgentZone.find(params[:agent_zone_id])
        end

        def set_agent_rel
          @agent_rel = @agent_zone.agent_rels.find(params[:id])
        end

        def agent_rel_params
          params.require(:agent_rel).permit(:weight)
        end
    end
  end
end
