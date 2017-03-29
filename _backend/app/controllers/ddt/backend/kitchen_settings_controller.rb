module Ddt
  class Backend::KitchenSettingsController < Backend::BaseController
    before_action :set_kitchen_setting, only: [:show, :edit, :update]
    layout 'ddt/layouts/backend/branch'

    def show
    end

    def edit
    end

    def update
      if @kitchen_setting.update(kitchen_setting_params)
        redirect_to backend_shop_branch_kitchen_setting_path(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/kitchen_setting')} 更新成功."
      else
        render :edit
      end
    end

    private
      def set_kitchen_setting
        @kitchen_setting = @current_branch.kitchen_setting
      end

      def kitchen_setting_params
        params.require(:kitchen_setting).permit(:warning_wait_minitue)
      end
  end
end
