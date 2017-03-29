module Ddt
  class Backend::ShakeAround::ApplyLogsController < Backend::BaseController
    include Ddt::RescueWeixinError
    before_action :set_wechat_account
    layout 'ddt/layouts/backend/wechat_account'

    weixin_crash_in :create, :redirect_to_action => :index

    def index
      @apply_logs = @wechat_account.apply_device_logs
    end

    def new
      @apply_log = @wechat_account.apply_device_logs.build
    end

    def create
      @apply_log = @wechat_account.apply_device_logs.build(apply_log_params)
      if @apply_log.save
        redirect_to action: :index
      else
        render :new
      end
    end

    private

    def set_wechat_account
      @wechat_account = @current_shop.wechat_accounts.find(params[:wechat_account_id]) rescue nil
    end

    def apply_log_params
      params.require(:shake_around_apply_log).permit(:apply_reason, :comment, :quantity, :poi_id)
    end

  end
end
