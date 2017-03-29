# encoding: utf-8
module Ddt
  class Backend::Admin::AgentsController < Backend::BaseAdminController
    before_action :set_agent, only: [:show, :edit, :update, :destroy, :reset_password]

    def index
      @q = Ddt::Agent.all.ransack(params[:q])
      @agents = @q.result.distinct.paginate(:page => params[:page], :per_page => 25)
      respond_to do |format|
        format.html
        format.json { render json: @agents.map(&:select_json) }
        format.csv do
          @agents = Ddt::Agent.all
          keys = %W[专属邀请码 是否是OEM厂商 公司名 代理类型 独家代理 名称 代理期限 余额 邮箱 电话 创建时间]
          result = CSV.generate() do |csv|
            csv << keys
            @agents.each do |agent|
              csv_line = []
              csv_line << agent.agent_no
              csv_line << (agent.is_oem? ? "是" : '否')
              csv_line << agent.agent_type_name
              csv_line << agent.company_name
              csv_line << (agent.exclusive? ? "是" : '否')
              csv_line << agent.name
              csv_line << agent.agent_rels.map{|rel| "#{rel.agent_zone.try(:name)}(#{rel.agent_from.strftime("%F")}~#{rel.agent_to.strftime("%F")})"}.join(" ")
              csv_line << agent.balance
              csv_line << agent.email
              csv_line << agent.phone
              csv_line << agent.created_at.strftime("%F")
              csv << csv_line
            end
          end
          send_data result, :filename => "代理商信息#{Time.now.strftime("%F")}.csv"
        end
      end
    end

    def reset_password
    end

    def show
    end

    def new
      @agent = Agent.new()
      @agent.agent_rels.build(agent_from: DateTime.now, agent_to: 1.year.from_now)
    end

    def edit
    end

    def create
      @agent = Agent.new(agent_params)
      unless @agent.is_oem?
        @agent.brand = "点单通"
        @agent.domain = Ddt::Host::DEPLOY
      end

      respond_to do |format|
        if @agent.save
          format.html { redirect_to [:backend, @agent], notice: 'Agent was successfully created.' }
          format.json { render action: 'show', status: :created, location: @agent }
        else
          format.html { render action: 'new' }
          format.json { render json: @agent.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @agent.update(agent_params)
          format.html { redirect_to [:backend, @agent], notice: 'Agent was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @agent.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @agent.destroy
      respond_to do |format|
        format.html { redirect_to backend_agents_url }
        format.json { head :no_content }
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_agent
      @agent = Ddt::Agent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agent_params
      params.require(:agent).permit(:agent_no, :email, :brand, :page_footer, :company_name, :password, :password_confirmation,
        :name, :is_oem, :domain, :wechat_introduce_url,  :phone, :balance, :mini_store_price,
        :standard_store_price, :multiple_store_price, :increase_per_store_cost, :can_sale_multiple_store,
        :chain_start_price, :chain_start_num, :can_create_account, :discount,
        :email_address, :email_user_name, :email_password, :agent_type, :exclusive, :can_buy_printer_code, :logo, :rect_logo, :alipay_agent_id,
        agent_rels_attributes: [:id, :agent_id, :agent_from, :agent_to, :agent_zone_id, :_destroy])
    end
  end
end
