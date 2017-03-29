module Ddt
  class ShopWeixinNotifyActionWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 5, :queue => :default

    def perform(user_id, article_options={})
      user = Ddt::User.find(user_id)
      wechat_user = user.try(:primary_wechat_user)
      if wechat_user && wechat_user.subscribed?
        user_open_id = wechat_user.try(:user_open_id)
        access_token = user.shop.primary_wechat_account.get_access_token
        material = Ddt::Material.new(msg_type: :news)
        material.articles.build(article_options)
        if user_open_id.present? && access_token.present?
          Rails.logger.warn "send custom message to user_open_id #{user_open_id}, access_token #{access_token}, material #{material}"
          begin
            WeixinApi.send_custom_message(material, user_open_id, access_token)
          rescue WeixinApi::WeixinApiError => e
            if e.errcode > 0
              params = [access_token, user_open_id].join(',')
              Rails.logger.error "WeixinApi.send_custom_message failed, #{params} , e.message"
            end
          end
        end
      end
    end
  end
end
