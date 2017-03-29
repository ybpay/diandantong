# encoding: utf-8
module Ddt
  class Backend::Admin::AgentZonesController < Backend::BaseAdminController
    before_action :set_agent_zone, only: [:show, :edit, :update, :destroy]

    def index
      respond_to do |format|
        format.html do
          @agent_zones = AgentZone.root_agent_zones
        end
      end
    end

    def show
    end

    def new
      @agent_zone = AgentZone.new
    end

    def edit
    end

    def create
      @agent_zone = AgentZone.create_linkage_zones_with_full_name(agent_zone_params[:full_name])
      redirect_to [:backend, @agent_zone], notice: 'Agent zone was successfully created.'
    rescue
      render action: 'new'
    end

    def update
      name = agent_zone_params[:name]
      if @agent_zone.name != name
        @agent_zone.update_name_recur(name)
      end
      redirect_to [:backend, @agent_zone], notice: 'Agent zone was successfully updated.'
    rescue
      render action: 'edit'
    end

    def destroy
      @agent_zone.destroy
      respond_to do |format|
        format.html { redirect_to backend_agent_zones_url }
        format.json { head :no_content }
      end
    end

    private
    def set_agent_zone
      @agent_zone = AgentZone.find(params[:id])
    end

    def agent_zone_params
      if action_name == 'create'
        params.require(:agent_zone).permit(:full_name)
      elsif action_name == 'update'
        params.require(:agent_zone).permit(:name)
      else
        params.require(:agent_zone).permit(:name, :full_name, :parent_agent_zone_id)
      end
    end
  end
end
