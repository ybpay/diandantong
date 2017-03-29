module Ddt
  module ShakeAround
    class Page < Ddt::Base
      # page_id
      # title
      # description
      # page_url
      # comment
      # icon_url
      # shop_id
      # wechat_account_id
      belongs_to :shop, class_name: 'Ddt::Shop'
      belongs_to :wechat_account, class_name: 'Ddt::WechatAccount'
      has_many :devices_pages, class_name: 'Ddt::ShakeAround::DevicesPage'
      has_many :devices, through: :devices_pages, class_name: 'Ddt::ShakeAround::Device'

      set_from :wechat_account, targets: [:shop_id]

      str_tokenizer = ->(str) { (1..str.width).to_a }

      validates_presence_of :title, :description
      validates_length_of :title, maximum: 6, tokenizer: str_tokenizer
      validates_length_of :description, maximum: 30, tokenizer: str_tokenizer
      validates_length_of :comment, maximum: 30, tokenizer: str_tokenizer, if: :comment_present?

      filter_urls_for :page_url

      before_create :add_page
      before_destroy :destroy_page

      def bindable_devices
        result = wechat_account.devices.where("count < 30")
        result = result.where("id not in (?)", self.device_ids) if self.device_ids.present?
        result
      end

      def self.refresh(wechat_account)
        offset = wechat_account.pages.count
        result = Ddt::WeixinApi.page_search_by_page(wechat_account.get_access_token, offset, 50)
        result[:pages].each do |new_page|
          wechat_account.pages.create(new_page)
        end
      end

      def refresh
        result = Ddt::WeixinApi.page_search_by_ids(access_token, [self.page_id])
        self.update(result[:pages][0])
      end

      def upload_icon(file)
        result = Ddt::WeixinApi.material_add(access_token, file)
        self.icon_url = result
      end

      def edit
        result = Ddt::WeixinApi.page_update(access_token, self.page_id, self.title, self.description, self.page_url, self.icon_url, self.comment)
      end

      def access_token
        wechat_account.get_access_token
      end

      def comment_present?
        self.comment.present?
      end

      private
        def add_page
          page_id = Ddt::WeixinApi.page_add(access_token, self.title, self.description, self.page_url, self.icon_url, self.comment)
          self.page_id = page_id
        end

        def destroy_page
          Ddt::WeixinApi.page_delete(access_token, [self.page_id])
        end
    end
  end
end
