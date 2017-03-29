module Ddt
  module Backend
    module SetAgentBrand
      extend ActiveSupport::Concern
      included do
        before_action :set_oem_brand
        private

        def set_oem_brand
          agent = nil
          shop = nil
          if params[:agent_no].present?
            agent = (Ddt::Agent.find_by(agent_no: params[:agent_no]) rescue nil)
            @agent_no = agent.agent_no
          elsif ![Ddt::Host::DEPLOY, Ddt::Host::LOCAL].include?(request.host)
            agent = (Ddt::Agent.find_by(:domain => request.host) rescue nil)
            if agent.blank?
              shop = (Ddt::Shop.find_by(:custom_domain => request.host) rescue nil)
            else
              @agent_no = agent.agent_no
            end
          end

          if agent.present? && agent.is_oem?
            @oem_brand = agent.brand
            @oem_page_footer = agent.page_footer
            @oem_logo_url = agent.logo_url
            @oem_rect_logo_url = agent.rect_logo_url
          elsif shop.present? && shop.use_custom_brand?
            @oem_brand = shop.custom_brand_name
            @oem_page_footer = "ALL Rights Reserved.#{shop.custom_brand_name} 版权所有"
            @oem_logo_url = shop.image_url
            @oem_rect_logo_url = shop.rect_image_url
          end
        end
      end
    end
  end
end
