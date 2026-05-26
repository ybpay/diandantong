module Ddt
  class WechatViewRecord < Ddt::Base

    belongs_to :viewed_user, class_name: "Ddt::BaseUser", foreign_key: :base_user_id
    belongs_to :wechat_share_record, class_name: 'Ddt::WechatShareRecord', counter_cache: :viewed_users_count

    after_save :create_share_event

    def create_share_event
      wechat_share_record.reload
      if wechat_share_record.viewed_users_count > 0
        Ddt::Promotion::Events::ShareToFriendCircle.create!(base_user_id: wechat_share_record.user_id, shop_id: wechat_share_record.shop_id, wechat_share_record: wechat_share_record)
      end
    end
  end
end
