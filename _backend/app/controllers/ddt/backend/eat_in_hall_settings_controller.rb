module Ddt
  class Backend::EatInHallSettingsController < Backend::BaseController
    check_permission :branch, :eat_in_hall_setting, {show: :show, [:edit, :update] => :update}
    before_action :set_eat_in_hall_setting, only: [:show, :edit, :update]
    layout 'ddt/layouts/backend/branch'

    def show
    end

    def edit
    end

    def update
      if @eat_in_hall_setting.update(eat_in_hall_setting_params)
        redirect_to backend_shop_branch_eat_in_hall_setting_path(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/eat_in_hall_setting')} 更新成功."
      else
        render :edit
      end
    end

    private
      def set_eat_in_hall_setting
        @eat_in_hall_setting = @current_branch.eat_in_hall_setting
      end

      def eat_in_hall_setting_params
        params.require(:eat_in_hall_setting).permit(:auto_clear_table, :disable_service, :can_place_when_zero, :auto_pay_when_zero, :mode, :accessable_ssid_for_app, :confirm_type)
      end
  end
end
