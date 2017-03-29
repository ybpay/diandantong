#encoding: utf-8
module Ddt
  class Agentsys::AgentPrintersController < Agentsys::BaseController
    before_action :set_agent_printer, only: [:edit, :update]

    def index
      @agent_printers = current_agentsys_agent.agent_printers.paginate(page: params[:page])
    end
    

    private
    def set_agent_printer
      @agent_printer = current_agentsys_agent.agent_printers.find(params[:id])
    end
  end
end
