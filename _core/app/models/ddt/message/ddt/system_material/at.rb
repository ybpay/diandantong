# encoding: utf-8
module Ddt
  module SystemMaterial
    class At < ::Ddt::SystemMaterial::Base
      def build_message
        items = []
        items << {title: '点击图片即可自动绑定！',description: '还没绑定该公众帐号吗? 猛戳这里 >>>'}
        response_news_msg(items)
      end
    end
  end
end
