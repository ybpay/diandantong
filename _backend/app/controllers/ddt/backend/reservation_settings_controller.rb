module Ddt
  class Backend::ReservationSettingsController < Backend::BaseController
    check_permission :branch, :reservation_setting, { show: :show, [:edit, :update] => :update}
    before_action :set_reservation_setting, only: [:show, :edit, :update]
    layout 'ddt/layouts/backend/branch'

    def show
    end

    def edit
    end

    def update
      if @reservation_setting.update(reservation_setting_params)
        redirect_to backend_shop_branch_reservation_setting_path(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/reservation_setting')} 更新成功."
      else
        render :edit
      end
    end

    private
      def set_reservation_setting
        @reservation_setting = @current_branch.reservation_setting
      end

      def reservation_setting_params
        params.require(:reservation_setting).permit(:average_consumption, :prepayment_type, :max_reservation_days)
      end
  end
end
