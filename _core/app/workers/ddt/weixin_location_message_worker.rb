module Ddt
  class WeixinLocationMessageWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 0, :queue => :default
    def perform(shop_id, message_params={})
      shop = Shop.find(shop_id)
      message = MessageReception.new({shop: shop}.merge(message_params))
      WechatSubscribeRelationship.add_relationship(message.to_user_name, message.from_user_name) if message.from_user_name.present?
      user = message.wechat_user.user
      if user.present? && user.updated_at < 1.minute.ago
        user.update(
          last_latitude:  message.latitude,
          last_longitude: message.longitude
        )
      end
    end
  end
end
