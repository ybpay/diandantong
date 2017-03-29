module Ddt
  class Backend::ArrangingSettingsController < Backend::BaseController
    check_permission :branch, :arranging_setting, { :show => :show, [:edit, :update] => :update }
    before_action :set_arranging_setting, only: [:show, :edit, :update]
    layout 'ddt/layouts/backend/branch'

    def show
    end

    def edit
    end

    def update
      if @arranging_setting.update(arranging_setting_params)
        redirect_to backend_shop_branch_arranging_setting_path(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/arranging_setting')} 更新成功."
      else
        render :edit
      end
    end

    private
      def set_arranging_setting
        @arranging_setting = @current_branch.arranging_setting
      end

      def arranging_setting_params
        params.require(:arranging_setting).permit(:mode)
      end
  end
end
