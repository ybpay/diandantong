#encoding: utf-8
module Ddt
  class Agentsys::AgentsController < Agentsys::BaseController
    def profile
      @agent = current_agentsys_agent
    end

    def update_profile
      @agent = current_agentsys_agent
      if @agent.update(agent_params)
        redirect_to agentsys_profile_path, :notice=>"个人信息修改成功"
      else
        render :action => 'edit_profile'
      end
    end

    def edit_profile
      @agent = current_agentsys_agent
    end

    protected
    def agent_params
      if current_agentsys_agent.is_oem?
        params.require(:agent).permit(:phone, :brand, :domain, :company_name, :wechat_introduce_url, :email_address, :email_user_name, :email_password, :logo, :rect_logo, :user_id, :qq)
      else
        params.require(:agent).permit(:phone, :company_name, :wechat_introduce_url, :user_id, :qq)
      end
    end
  end
end
