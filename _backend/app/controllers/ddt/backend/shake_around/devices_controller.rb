module Ddt
  class Backend::ShakeAround::DevicesController < Backend::BaseController
    include Ddt::RescueWeixinError
    before_action :set_wechat_account
    before_action :set_device, only: [:show, :edit, :update, :get_bind, :bindable, :bind, :unbind]
    layout 'ddt/layouts/backend/wechat_account'

    weixin_crash_in :refresh, :show, :bind, :unbind, :redirect_to_action => :index


    def index
      @q = @wechat_account.devices.ransack(params[:q])
      @devices = @q.result.paginate(page: params[:page])
    end

    def refresh
      result = Ddt::ShakeAround::Device.refresh(@wechat_account)
      redirect_to action: :index
    end

    def show
      @device.refresh
    end

    def edit
    end

    def update
      @device.update(comment: params[:shake_around_device][:comment])
      render :show
    end

    def get_bind
      @mode = "binded"
      @pages = @device.bind_pages.paginate(page: params[:page])
      render "ddt/backend/shake_around/pages/index"
    end

    def bindable
      @mode = "bindable"
      @pages = @device.bindable_pages.paginate(page: params[:page])
      render "ddt/backend/shake_around/pages/index"
    end

    def bind
      ids = device_params[:page_ids]
      page_ids = @wechat_account.pages.where(id: ids).select(:page_id).map(&:page_id)
      Ddt::ShakeAround::DevicesPage.bind_pages(@wechat_account.get_access_token, @device, ids, page_ids)
      redirect_to action: :index
    end

    def unbind
      ids = device_params[:page_ids]
      page_ids = @wechat_account.pages.where(id: ids).select(:page_id).map(&:page_id)
      Ddt::ShakeAround::DevicesPage.unbind_pages(@wechat_account.get_access_token, @device, ids, page_ids)
      redirect_to action: :get_bind
    end

    private

    def set_wechat_account
      @wechat_account = @current_shop.wechat_accounts.find(params[:wechat_account_id]) rescue nil
    end

    def set_device
      @device = @wechat_account.devices.find(params[:id])
    end

    def device_params
      if ["bind", "unbind"].include? action_name
        params.require(:page).permit(page_ids: [])
      end
    end

  end
end
