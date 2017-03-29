module Ddt
  class WeixinApplicationController < Ddt::BaseWeixinController
    layout 'ddt/layouts/weixin'
    before_filter :record_viewed_user
    check_feature :weixin

    private
    def record_viewed_user
      if params[:wechat_share_record_trigger_timestamp]
        wechat_share_record = @current_shop.wechat_share_records.find_by_trigger_timestamp(params[:wechat_share_record_trigger_timestamp]) rescue nil
        if wechat_share_record.present?
          wechat_view_record = wechat_share_record.wechat_view_records.find_by(viewed_user: @current_user)
          if wechat_view_record.present?
            wechat_view_record.touch(:updated_at)
          else
            # 用户手机响应慢，连接点分享链接，会使这里重入
            wechat_view_record = wechat_share_record.wechat_view_records.build(viewed_user: @current_user)
            begin
              wechat_view_record.save!
            rescue ActiveRecord::RecordNotUnique => e
              Rails.logger.warn("insert duplicate wechat_view_record: share_record_id=#{wechat_share_record.id}, viewed_user_id=#{@current_user.id}")
            end
          end
        end
      end
    end
  end
end
