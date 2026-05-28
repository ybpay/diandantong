# encoding: utf-8
module Ddt
  class ProtocolsController < ActionController::Base

    def index
      @agent = Ddt::Agent.with_discarded.find_by(agent_no: params[:agent_no]) if params[:agent_no].present?
      @agent = Ddt::Agent.with_discarded.find_by(domain: request.host) unless [Ddt::Host::DEPLOY, Ddt::Host::LOCAL].include? request.host

      if @agent.present?
        @company_name = @agent.support_company_name
        @brand_name = @agent.support_brand_name
      else
        @company_name = Ddt::SiteConfig.company_name
        @brand_name = Ddt::SiteConfig.brand_name
      end
      render Ddt::EULA.protocol_path
    end

  end
end
