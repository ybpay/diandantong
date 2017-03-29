#encoding: utf-8
module Ddt
  class Backend::ShakeAround::PagesController < Backend::BaseController
    include Ddt::RescueWeixinError
    before_action :set_wechat_account
    before_action :set_page, only: [:show, :edit, :update, :destroy, :get_bind, :bindable, :bind, :unbind]
    layout 'ddt/layouts/backend/wechat_account'

    weixin_crash_in :create, :redirect_to_action => :new
    weixin_crash_in :update, :redirect_to_action => :edit
    weixin_crash_in :unbind, :redirect_to_action => :get_bind
    weixin_crash_in :refresh, :show, :destroy, :bind, :redirect_to_action => :index

    def index
      @q = @wechat_account.pages.ransack(params[:q])
      @pages = @q.result.paginate(page: params[:page])
    end

    def new
      @page = @wechat_account.pages.build
    end

    def create
      attrs = _page_params
      file = attrs.delete(:icon_url)
      @page = @wechat_account.pages.build(attrs)
      if @page.valid?
        if file.present?
          @page.upload_icon(file.tempfile)
          @page.save
          redirect_to action: :index
        else
          @page.errors.add(:icon_url, "请选择图片")
          render :new
        end
      else
        render :new
      end
    end

    def edit
    end

    def update
      attrs = _page_params
      file = attrs.delete(:icon_url)
      @page.attributes = @page.attributes.merge! attrs
      if @page.valid?
        if file.present?
          @page.upload_icon(file.tempfile)
          @page.edit
          @page.save
          redirect_to action: :index
        else
          @page.edit
          @page.save
          redirect_to action: :index
        end
      else
        render :new
      end
    end

    def destroy
      @page.destroy
    end


    def refresh
      Ddt::ShakeAround::Page.refresh(@wechat_account)
      redirect_to action: :index
    end

    def show
      @page.refresh
    end

    def get_bind
      @mode = "binded"
      @devices = @page.devices.paginate(page: params[:page])
      render "ddt/backend/shake_around/devices/index"
    end

    def bindable
      @mode = "bindable"
      @devices = @page.bindable_devices.paginate(page: params[:page])
      render "ddt/backend/shake_around/devices/index"
    end

    def bind
      ids = _page_params[:device_ids]
      device_ids = @wechat_account.devices.where(id: ids).select(:device_id).map(&:device_id)
      Ddt::ShakeAround::DevicesPage.bind_devices(@wechat_account.get_access_token, @page, ids, device_ids)
      redirect_to action: :index
    end

    def unbind
      ids = _page_params[:device_ids]
      device_ids = @wechat_account.devices.where(id: ids).select(:device_id).map(&:device_id)
      Ddt::ShakeAround::DevicesPage.unbind_devices(@wechat_account.get_access_token, @page, ids, device_ids)
      redirect_to action: :get_bind
    end

    private

    def set_wechat_account
      @wechat_account = @current_shop.wechat_accounts.find(params[:wechat_account_id]) rescue nil
    end

    def set_page
      @page = @wechat_account.pages.find(params[:id])
    end

    def _page_params
      if ["bind", "unbind"].include? action_name
        params.require(:device).permit(device_ids: [])
      else
        params.require(:shake_around_page).permit(:title, :description, :page_url, :icon_url, :comment)
      end
    end

  end
end
