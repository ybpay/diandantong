module Ddt
  class Backend::ShortMessageSettingsController < Backend::BaseController
    check_permission :shop, :short_message_setting, { show: :show, [:edit, :update] => :update}
    before_action :set_short_message_setting, only: [:show, :edit, :update]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/short_message' }
    def show
    end

    def edit

    end

    def update
      # if @short_message_setting.use_sms?
        if @short_message_setting.update(short_message_setting_params)
          @current_shop.touch
          flash[:notice] = '短信设置修改成功'
          redirect_to [:backend, @current_shop, :short_message_setting]
        else
          render 'edit'
        end
      # else
      #   flash[:notice] = '短信功能暂停服务'
      #   redirect_to [:backend, @current_shop, :short_message_setting]
      # end
    end

    private

    def set_short_message_setting
      @short_message_setting = @current_shop.short_message_setting
    end

    def short_message_setting_params
      if current_account.is_admin?
        params.require(:short_message_setting).permit(:use_sms, :use_validation_sms, :use_order_sms, :use_birthday_sms, :birthday_message, :max_count, :enable_vip_info_phone_validation)
      else
        params.require(:short_message_setting).permit(:use_sms, :use_validation_sms, :use_order_sms, :use_birthday_sms, :birthday_message, :enable_vip_info_phone_validation)
      end
    end
  end
end
