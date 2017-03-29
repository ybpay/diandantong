module Ddt
  class Backend::NotificationReceiveSettingsController < Backend::BaseController
    check_permission :shop, :account, { show: :show, [:edit, :update] => :update }
    before_action :set_account
    before_action :set_notification_receive_setting

    def show
    end

    def edit
    end

    def update
      if @notification_receive_setting.update(setting_params)
        redirect_to backend_shop_account_notification_receive_setting_path(@current_shop, @account)
      else
        render :edit
      end
    end


    private
    def set_account
      @account = @current_shop.accounts.find(params[:account_id])
    end

    def set_notification_receive_setting
      @notification_receive_setting = @account.notification_receive_setting
    end

    def setting_params
      params.require(:notification_receive_setting).permit(*NotificationReceiveSetting.all_settings)
    end
  end
end
