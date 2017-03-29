module Ddt
  class Backend::FeatureModulesConfigsController < Backend::BaseController
    check_permission :shop, :feature_modules_config, { [:index_group, :index] => :show, [:edit, :update] => :update}
    before_action :set_feature_modules_config, only: [:show, :update, :edit, :destroy]

    def index
      @feature_modules_configs = @current_shop.feature_modules_configs
    end

    def show
    end

    def update
      if @feature_modules_config.update(feature_modules_config_params)
        @feature_modules_config.touch
        redirect_to [:backend, @current_shop, :feature_modules_configs]
      else
        render :edit
      end
    end



    def price_of_charge_version
      if params[:feature_module_group].present? && params[:increment_days].present? && params[:branch_num].present?

        price = Ddt::FeatureModuleGroup.price_of_charge_version(@current_shop, 
          @current_shop.expiration_time + params[:increment_days].to_i.days, 
          params[:branch_num].to_i, 
          params[:feature_module_group])
        render json: {price: price}
      else
        head :no_content
      end
    end

    def new
      @feature_modules_config = @current_shop.feature_modules_configs.build
    end

    def create
      @feature_modules_config = @current_shop.feature_modules_configs.build(feature_modules_config_params)
      if @feature_modules_config.save
        redirect_to [:backend, @current_shop, :feature_modules_configs]
      else
        render :new
      end
    end



    def destroy
      @feature_modules_config.destroy
      redirect_to [:backend, @current_shop, :feature_modules_configs], notice: '模块已删除'
    end

    def edit
    end

    private 
    def set_feature_modules_config
      @feature_modules_config = @current_shop.feature_modules_configs.find(params[:id])
    end

    def feature_modules_config_params
      if current_account.is_admin?
        params.require(:feature_modules_config).permit(:feature_module, :expired_at, :enabled, :disable_reason)
      else
        params.require(:feature_modules_config).permit(:enabled, :disable_reason)
      end
    end
  end
end