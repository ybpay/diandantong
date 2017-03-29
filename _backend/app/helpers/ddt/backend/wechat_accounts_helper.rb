# encoding: utf-8
module Ddt
  module Backend
    module WechatAccountsHelper
      def edit_wechat_menu(wechat_account)
        if wechat_account.can_define_menu?
          link_to '配置菜单', backend_shop_wechat_account_wechat_menus_path(@current_shop, wechat_account)
        end
      end
    end
  end
end
