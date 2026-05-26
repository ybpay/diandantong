module Ddt
  class Weixin::WechatShareRecordsController < WeixinApplicationController

    before_action :set_wechat_share_record, only: [:confirm, :show]

    def create
      @wechat_share_record = @current_user.wechat_share_records.build(shop: @current_shop, trigger_timestamp: wechat_share_record_params[:trigger_timestamp])
      @wechat_share_record.save!
      render 'show'
    end

    def show
    end

    def index
      @wechat_share_records = @current_user.wechat_share_records.of_verified.paginate(page: params[:page], per_page: params[:per_page] || 8)
    end

    def confirm
      @wechat_share_record.attributes = wechat_share_record_params
      @wechat_share_record.verified = true
      if @wechat_share_record.save
        render 'show'
      else
        render json: { errors: @wechat_share_record.errors.full_messages }, status: :bad_request
      end
    end

    private
    def wechat_share_record_params
      params.require(:wechat_share_record).permit(:share_type, :title, :desc, :link, :img_url, :trigger_timestamp)
    end

    def set_wechat_share_record
      @wechat_share_record = @current_user.wechat_share_records.find(params[:id])
    end

  end
end