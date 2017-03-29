# encoding: utf-8
module Ddt
  class Agentsys::ShopRechargeRecordsController < Agentsys::BaseController
    before_action :set_shop_recharge_record, only: [:show]
    before_action :set_shop
 

    def index
      if params[:shop_id].present?
        @shop_recharge_records = current_agentsys_agent.shop_recharge_records.where(:shop_id => params[:shop_id]).order(created_at: :desc).ransack(params[:q]).result(distinct: true).paginate(page: params[:page], per_page: 10)
      else
        @shop_recharge_records = current_agentsys_agent.shop_recharge_records.order(created_at: :desc).ransack(params[:q]).result(distinct: true).paginate(page: params[:page], per_page: 10)
      end
    end

    def show
    end

    def new_free
      @current_shop = Ddt::Shop.find(params[:shop_id])
      if @current_shop.can_recharge_free?
        @shop_recharge_record = @current_shop.shop_recharge_records.build(increment_days: (@current_shop.max_recharge_free_time/3600/24-1))
      else
        redirect_to agentsys_shops_path, notice: '该帐号试用时间超过一个月，不允许再继续免费试用'
      end
    end

    def create_free
      if @current_shop.can_recharge_free? && shop_recharge_record_params[:increment_days].to_i <= (@current_shop.max_recharge_free_time/3600/24-1)
        @shop_recharge_record = @current_shop.shop_recharge_records.build(increment_days: shop_recharge_record_params[:increment_days])
        @shop_recharge_record.recharge_type = :base
        @shop_recharge_record.beginning_time = [DateTime.now, @current_shop.expiration_time].max
        @shop_recharge_record.ending_time = @shop_recharge_record.beginning_time + shop_recharge_record_params[:increment_days].to_i
        @shop_recharge_record.agent = current_agentsys_agent
        @shop_recharge_record.branch_num = @current_shop.max_branches_limit
        @shop_recharge_record.price = 0
        @shop_recharge_record.original_price = 0
        if @shop_recharge_record.save
          Ddt::FeatureModuleGroup.send(:trial)[:modules].map do |fm|
            feature_module_config = @current_shop.feature_modules_configs.find_by(feature_module: fm)
            feature_module_config.expired_at = [feature_module_config.expired_at, @shop_recharge_record.ending_time].max
            feature_module_config.save
          end
          redirect_to agentsys_shop_recharge_records_path(shop_id: @current_shop.id), notice: "成功延长试用#{shop_recharge_record_params[:increment_days]}天"
        else
          render 'new_free'
        end
      else
        redirect_to agentsys_shops_path(shop_id: @current_shop.id), notice: "对不起，延长时间超过了允许的范围"
      end
    end

    def new
      @shop_recharge_record = @current_shop.shop_recharge_records.build(increment_days: params[:increment_days])
      @shop_recharge_record.recharge_type = @current_shop.shop_type
      if params[:feature_module_group].present? && Ddt::FeatureModuleGroup.all.include?(params[:feature_module_group].to_sym)
        @shop_recharge_record.recharge_type = params[:feature_module_group]
      end

      if @shop_recharge_record.recharge_type.to_sym == :base && !current_agentsys_agent.is_hardware_level?
        redirect_to index_group_agentsys_feature_modules_configs_path(shop_id: params[:shop_id]), notice: '不允许的续费类型'
      end
      @shop_recharge_record.branch_num = @current_shop.max_branches_limit
      @shop_recharge_record.beginning_time = [DateTime.now, @current_shop.expiration_time].max
      @shop_recharge_record.ending_time = @current_shop.expiration_time
      @shop_recharge_record.agent = current_agentsys_agent
      if @shop_recharge_record.increment_days.present?
        @shop_recharge_record.ending_time = @shop_recharge_record.beginning_time + @shop_recharge_record.increment_days.days
      end

      @left_days_price =  Ddt::FeatureModuleGroup.price_of_charge_version(@current_shop, 
          @current_shop.expiration_time, 
          @shop_recharge_record.branch_num, 
          @shop_recharge_record.recharge_type).round(2)
      @append_days_price = Ddt::FeatureModuleGroup.amount_of(@shop_recharge_record.recharge_type, 
        @shop_recharge_record.increment_days,
        @shop_recharge_record.branch_num)


      @shop_recharge_record.original_price = Ddt::FeatureModuleGroup.price_of_charge_version(@current_shop, @shop_recharge_record.ending_time, @current_shop.max_branches_limit, @shop_recharge_record.recharge_type)
      @shop_recharge_record.price = (@shop_recharge_record.original_price * current_agentsys_agent.discount).round(2)

    end

    def create
      @shop_recharge_record = @current_shop.shop_recharge_records.build(shop_recharge_record_params)
      if @shop_recharge_record.recharge_type.to_sym == :base && !current_agentsys_agent.is_hardware_level?
        redirect_to index_group_agentsys_feature_modules_configs_path(shop_id: params[:shop_id]), notice: '不允许的续费类型'
      end
      @shop_recharge_record.beginning_time = [DateTime.now, @current_shop.expiration_time].max

      max_agent_to = current_agentsys_agent.agent_rels.maximum(:agent_to)
      if @shop_recharge_record.increment_days > 0 && @current_shop.expiration_time  > max_agent_to
        redirect_to new_agentsys_shop_recharge_record_path(shop_id: params[:shop_id]), notice: "您的代理期限到#{max_agent_to}截止，您为客户充值的时间已经超过了您的代理期限，不允许为代理期限之外的客户充值，仅可续费"
        return
      end
      @shop_recharge_record.ending_time = [DateTime.now, @current_shop.expiration_time].max
      @shop_recharge_record.agent = current_agentsys_agent
      if @shop_recharge_record.increment_days.present?
        @shop_recharge_record.ending_time = @shop_recharge_record.beginning_time + @shop_recharge_record.increment_days.days
      end
      @shop_recharge_record.original_price = Ddt::FeatureModuleGroup.price_of_charge_version(@current_shop, @shop_recharge_record.ending_time, @shop_recharge_record.branch_num, @shop_recharge_record.recharge_type)
      @shop_recharge_record.price = (@shop_recharge_record.original_price * current_agentsys_agent.discount).round(2)
      if @shop_recharge_record.save
        redirect_to agentsys_shop_recharge_records_path(shop_id: @current_shop.id), notice: "充值成功"
      else
        render 'new'
      end
    end
    
    private

    def set_shop
      if params[:shop_id].present?
        @current_shop = current_agentsys_agent.shops.find{|shop| shop.id == params[:shop_id].to_i}
      elsif @shop_recharge_record.present?
        @current_shop = current_agentsys_agent.shops.find{|shop| shop.id == @shop_recharge_record.shop_id.to_i}
      end
    end

    def set_agent
      @agent = current_agentsys_agent
    end

    def set_shop_recharge_record
      @shop_recharge_record = current_agentsys_agent.shop_recharge_records.find(params[:id])
    end

    def shop_recharge_record_params
      if action_name == 'create' || action_name == 'create_free'
        params.require(:shop_recharge_record).permit(:increment_days, :branch_num, :note, :recharge_type, :shop)
      else
        params.require(:shop_recharge_record).permit(:note)
      end
    end
  end
end
