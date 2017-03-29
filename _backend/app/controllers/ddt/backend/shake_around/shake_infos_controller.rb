#encoding: utf-8
module Ddt
  class Backend::ShakeAround::ShakeInfosController < Backend::BaseController

    before_action :set_wechat_account
    before_action :set_infos

    layout 'ddt/layouts/backend/wechat_account'

    def index
      @q = @infos.order(created_at: :desc).ransack(params[:q])
      @shake_infos = @q.result.paginate(page: params[:page])
    end

    private
      def set_wechat_account
        @wechat_account = @current_shop.wechat_accounts.find(params[:wechat_account_id])
      end

      def set_infos
        condition = {wechat_account_id: @wechat_account.id}
        if params[:device_id].present?
          @device = @wechat_account.devices.find params[:device_id]
          condition = condition.merge(device_id: @device.device_id)
        else
          @page = @wechat_account.pages.find params[:page_id]
          condition = condition.merge(page_id: @page.page_id)
        end
        @infos = Ddt::ShakeAround::ShakeInfo.where(condition).includes(:unique_user)
      end

  end
end
