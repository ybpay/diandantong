# encoding: utf-8
module Ddt
  class Agentsys::FeatureModulesConfigsController < Agentsys::BaseController
    before_action :set_shop


    def index_group

    end
    
    def index
      @feature_modules_configs = @current_shop.feature_modules_configs
    end

    def price_of_charge_version
      if params[:feature_module_group].present? && params[:increment_days].present? && params[:branch_num].present?

        original_price = Ddt::FeatureModuleGroup.price_of_charge_version(@current_shop, 
          @current_shop.expiration_time + params[:increment_days].to_i.days, 
          params[:branch_num].to_i, 
          params[:feature_module_group])
        price = (original_price * current_agentsys_agent.discount).round(2)
        left_days_price =  Ddt::FeatureModuleGroup.price_of_charge_version(@current_shop, 
          @current_shop.expiration_time, 
          params[:branch_num].to_i, 
          params[:feature_module_group]).round(2)
        append_days_price = Ddt::FeatureModuleGroup.amount_of(params[:feature_module_group], 
          params[:increment_days].to_i, 
          params[:branch_num].to_i||@current_shop.max_branches_limit)


        render json: {price: price , original_price: original_price, append_days_price: append_days_price, left_days_price: left_days_price}
      else
        head :no_content
      end
    end

    private

    def set_shop
      if params[:shop_id].present?
        @current_shop = current_agentsys_agent.shops.find{|shop| shop.id == params[:shop_id].to_i}
      end
    end

    def set_agent
      @agent = current_agentsys_agent
    end

  end
end
