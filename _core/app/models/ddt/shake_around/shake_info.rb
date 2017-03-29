#encoding: utf-8
module Ddt
  module ShakeAround
    class ShakeInfo < Ddt::Base
      # user_open_id
      # user_id
      # unique_user_id
      # page_id
      # poi_id
      # is_from_notify boolean, false 为通过ticket 获取的信息
      # shake_time
      # wechat_account_wxhao # 开发者微信号,我们可能无法获取到是哪个公众号，如果客户没有如实填写微信号的话
      # wechat_account_id
      # shop_id
      # device_id
      # distance

      belongs_to :wechat_account, class_name: 'Ddt::WechatAccount'
      belongs_to :user, class_name: 'Ddt::User'
      belongs_to :unique_user, class_name: 'Ddt::UniqueUser'
      has_many :beacon_infos, class_name: 'Ddt::ShakeAround::BeaconInfo'

      def chosen_beacon_info
        beacon_infos.select{|info| info.is_chosen? }.first
      end

      before_create :set_device_id

      def action_label
        is_from_notify ? "摇一摇" : "进入页面"
      end

      private

      def set_device_id
        beacon_info = chosen_beacon_info
        self.device_id = beacon_info.device_id
        self.distance = beacon_info.distance
        if self.wechat_account_id.blank? || self.shop_id.blank?
          self.shop_id = beacon_info.shop_id
          self.wechat_account_id = beacon_info.wechat_account_id
        end
      end


    end
  end
end
