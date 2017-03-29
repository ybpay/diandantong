# encoding:utf-8
module Ddt
  module Backend
    module VipInfosHelper
      def verify_label(vip_info)
        if vip_info.is_verified
          content_tag(:span, '已认证', class: "label label-success")
        else
          content_tag(:span, '未认证', class: "label label-warning")
        end
      end
    end
  end
end