# encoding: utf-8
module Ddt
  class Agentsys::AgentMaterialsController < Agentsys::BaseController

    def show
      @agent_material = AgentMaterial.find(params[:id])
    end

    def index
      @agent_materials = AgentMaterial.all
    end

  end
end
