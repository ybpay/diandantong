# encoding: utf-8
module Ddt
  module Backend
    module WechatMenusHelper
      def action_of_menu(menu)
        if menu.button_menu?
          if menu.material_id.present?
            return "回复素材： #{menu.material.try(:material_name)}"
          elsif menu.keyword.present?
            return "回复系统动作： #{Ddt::Event::system_keyword_name(menu.keyword.to_sym)}"
          elsif menu.url.present?
            return "跳转到链接： #{menu.url}"
          else
            return ""
          end
        elsif menu.folder_menu?
          ""
        end
      end
    end
  end
end