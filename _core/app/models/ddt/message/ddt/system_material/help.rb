# encoding: utf-8
module Ddt
  module SystemMaterial
    class Help < ::Ddt::SystemMaterial::Base
      def build_message
        description = "#{shop.introduction_decoder} \n\n点击进入>>>"
        url = branch_url
        if wechat_account.present? && wechat_account.default_branch.present?
          description = "#{wechat_account.default_branch.introduction_decoder} 欢迎您使用微信下单"
          url = branch_url(wechat_account.default_branch)
        end
        items = [{title: welcome_msg, description: description, pic_url: shop.rect_image_variant(:medium),url: url}]
        response_news_msg(items)
      end
    end
  end
end
