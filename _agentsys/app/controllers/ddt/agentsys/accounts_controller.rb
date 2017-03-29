module Ddt
  class Agentsys::AccountsController < Agentsys::BaseController
    def new
      if current_agentsys_agent.can_create_account?
     	  @account=Account.new    
      else
        redirect_to agentsys_shops_path
      end
    end

    def create
      if current_agentsys_agent.can_create_account?
        new_params = {}
        permit_params = account_params
        [:login_id, :name, :email, :phone, :password, :password_confirmation].each {|key| new_params[key] = account_params[key]}
        @account = Account.new(new_params)
        @account.captcha_valid = true
        permit_params[:shop_attributes] = Hash.new
        permit_params[:shop_attributes][:agent_no] = current_agentsys_agent.agent_no

        if @account.init(permit_params, track_from: :FromAgent)
          @account.roles = @account.shop.roles.boss_role

          redirect_to url_helpers.agentsys_shops_path ,notice: "创建用户成功"
        else
          render :new
        end
      else
        redirect_to url_helpers.agentsys_shops_path ,alert: "不允许创建帐户"
      end
    end
    private
    def account_params
      params.require(:account).permit(:phone, :name, :password, :password_confirmation, :login_id, :email, :notification_email, :receive_email, :user_id,:shop_id,:built_in)
    end
  end

end