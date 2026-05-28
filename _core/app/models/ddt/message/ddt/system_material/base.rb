#encoding: utf-8
module Ddt
  module SystemMaterial
    class Base
      include Rails.application.routes.url_helpers
      attr_reader :message_reception
      delegate :shop, :wechat_account, :wechat_user, :user, to: :message_reception
      alias_method :message, :message_reception
      def initialize(message_reception)
        @message_reception = message_reception
      end

      def build_message
        raise "should be overwrite in (#{self.class.name})"
      end

      private

      # 默认链接
      def branch_url(branch=nil)
        if branch.nil?
          return Ddt::LinkResource.new(shop: shop).shop_home_url
        else
          return Ddt::LinkResource.new(shop: shop, branch: branch, querys: { from_branch_id: branch.id }).branch_home_url
        end
      end

      # 默认封面图
      def cover_img_url
        if wechat_account.present? && wechat_account.default_branch.present?
          pic_url = wechat_account.default_branch.rect_image_variant(:medium)
        end
        pic_url.present? ? pic_url : shop.rect_image_variant(:medium)
      end

      def welcome_msg
        if wechat_account.present? && wechat_account.default_branch.present?
          "#{wechat_account.default_branch.name}欢迎您的关注"
        else
          "#{shop.name}欢迎您的关注"
        end
      end

      def response_news_msg(response_items)
        message_response = message_reception.create_message_response!(msg_type: :news)
        response_items[0..9].each do |item|
          message_response.message_response_items.create(
            title:       item[:title],
            description: item[:description],
            pic_url:     item[:pic_url] || cover_img_url,
            url:         item[:url] || branch_url(nil))
        end
        message_response
      end

    end
  end
end
