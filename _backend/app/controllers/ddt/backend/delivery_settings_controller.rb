module Ddt
  class Backend::DeliverySettingsController < Backend::BaseController
    check_permission :branch, :delivery_setting, {show: :show, [:edit, :update] => :update}
    before_action :set_delivery_setting, only: [:show, :edit, :update]
    layout 'ddt/layouts/backend/branch'

    def show
      if @delivery_setting.charge_by == "zone"
        @delivery_zones = @current_branch.delivery_zones
      elsif @delivery_setting.charge_by == "range"
        @delivery_ranges = @current_branch.delivery_ranges
      end
    end

    def edit
    end

    def update
      if @delivery_setting.update(delivery_setting_params)
        redirect_to backend_shop_branch_delivery_setting_path(@current_shop, @current_branch), notice: "#{t('activerecord.models.ddt/delivery_setting')} 更新成功."
      else
        render :edit
      end
    end

    private
      def set_delivery_setting
        @delivery_setting = @current_branch.delivery_setting
      end

      def delivery_setting_params
        params.require(:delivery_setting).permit(
          :support_delivery_if_amount_gt,
          :receive_delivery_order_within_days,
          :use_fixed_delivery_time,
          :support_order_if_not_in_delivery_radius,
          :delivery_radius,
          :delivery_need_minutes,
          :charge_by,
          :assign_mode,
          :unit,
          :per_unit_cost,
          :enable_auto_ship,
          :enable_auto_complete,
          :delivery_times_attributes => [:id, :start_time, :end_time, :cost, :cut_off_time, :enable_limit, :_destroy])
      end
  end
end
