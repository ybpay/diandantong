module Ddt
  class Backend::WechatShareRecordsController < Backend::BaseController
    check_permission :shop, :wechat_account, :manage
    before_action :set_wechat_share_record, only: [:show, :edit, :update, :destroy]
    respond_to :html

    def index
      @q = @current_shop.wechat_share_records.ransack(params[:q])
      @wechat_share_records = @q.result(distinct: true).paginate(page: params[:page])
      respond_with(@wechat_share_records)
    end

    def show
      respond_with(@wechat_share_record)
    end

    def destroy
      @wechat_share_record.destroy
      redirect_to [:backend, @current_shop, :wechat_share_records]
    end

    private
      def set_wechat_share_record
        @wechat_share_record = WechatShareRecord.find(params[:id])
      end

      def wechat_share_record_params
        params.require(:wechat_share_record).permit(:shop_id, :user_id, :share_type, :title, :desc, :link, :img)
      end
  end
end