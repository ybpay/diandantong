#encoding: utf-8
module Ddt
  module ShakeAround
    class Device < Ddt::Base
      # device_id
      # uuid
      # major
      # minor
      # status
      # poi_id
      # comment
      # apply_id
      # shop_id
      # wechat_account_id
      # last_active_time
      belongs_to :shop, class_name: 'Ddt::Shop'
      belongs_to :wechat_account, class_name: 'Ddt::WechatAccount'
      set_from :wechat_account, targets: [:shop_id]
      belongs_to :apply_log, class_name: 'Ddt::ShakeAround::ApplyLog'

      has_many :devices_pages, class_name: 'Ddt::ShakeAround::DevicesPage'
      has_many :bind_pages, through: :devices_pages, class_name: 'Ddt::ShakeAround::Page'

      validates_length_of :comment, maximum: 30, tokenizer: ->(str) { (1..str.width).to_a }, if: :comment_present?
      validates_presence_of :uuid, :major, :minor

      STATUS_LABEL = %W[未激活 已激活 活跃]

      #callback
      before_update :device_update, if: :comment_changed?

      def bindable_pages
        return [] if self.count == 30
        result = wechat_account.pages
        result = result.where("id not in (:ids)", ids: self.bind_page_ids) if self.bind_page_ids.present?
        result
      end

      def self.refresh(wechat_account)
        offset = wechat_account.devices.count
        result = Ddt::WeixinApi.device_search_by_page(wechat_account.get_access_token, offset, 50)
        result[:devices].each do |new_device|
          wechat_account.devices.create(new_device)
        end
      end

      def refresh
        result = Ddt::WeixinApi.device_search_by_ids(access_token, [self.device_id])
        self.update(result[:devices][0])
      end

      def status_name
        STATUS_LABEL[status]
      end

      def major_hex
        major.to_s(16)
      end

      def minor_hex
        minor.to_s(16)
      end

      def comment_present?
        self.comment.present?
      end

      def access_token
        wechat_account.get_access_token
      end

      def device_update
        Ddt::WeixinApi.device_update(access_token, self.device_id, self.comment)
      end

    end
  end
end
