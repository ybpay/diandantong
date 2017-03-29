# encoding: utf-8
module Ddt
  module Backend
    module ShopsHelper

      # version:
      #   only_ng        #/aaa/bbb
      #   path_and_ng    /weixin/shop/ddt?..&_ng_path=/aaa/bbb...
      #   whole_url      http://cy.diandantong.com/weixin/shop/ddt?..&_ng_path=/aaa/bbb...
      def shop_links(querys={})
        @links = Ddt::LinkResource.new(shop: @current_shop, querys: querys).shop_whole_urls
      end

      def branch_links(branch, querys={})
        @links = Ddt::LinkResource.new(shop: @current_shop, branch: branch, querys: querys).branch_whole_urls
      end

      def branches_link(querys={})
        @links = Ddt::LinkResource.new(shop: @current_shop, querys: querys).shop_branches_whole_url
      end

      def delivery_branches_link(querys={})
        @links = Ddt::LinkResource.new(shop: @current_shop, querys: querys).shop_delivery_branches_whole_url
      end

      def branches_by_tag_links(querys={})
        @links = Ddt::LinkResource.new(shop: @current_shop, querys: querys).shop_branches_by_tag_whole_urls
      end

      def delivery_branches_by_tag_links(querys={})
        @links = Ddt::LinkResource.new(shop: @current_shop, querys: querys).shop_delivery_branches_by_tag_whole_urls
      end

      def is_follow_wechat_account?
        # 如果当前微信公众号存在，则检查是否关注当前微信公众号
        if @current_wechat_account.present? and @current_user.wechat_users.where(gonghao_open_id: @current_wechat_account.gonghao_open_id, unsubscribed_at: nil)
            true
        # 否则，只要用户关注过任何公众号
        elsif @current_user.wechat_users.where(unsubscribed_at: nil).present?
          true
        else
          false
        end
      end

      # dashboard menus
      def dashboard_wechat_menus
        [

          [ {name: '微信外卖', icon: 'motorcycle',      color: 'orange', feature_module: :delivery_on_wechat},
            {name: '扫码堂点', icon: 'coffee',          color: 'blue',   feature_module: :eat_in_hall_on_wechat}],
          [ {name: '微信预定', icon: 'pencil-square-o', color: 'yellow', feature_module: :reservation_on_wechat},
            {name: '微信排队', icon: 'group',           color: 'green',  feature_module: :queue}],
          [ {name: '微信快餐', icon: 'cutlery',         color: 'blue',   feature_module: :fastfood_on_wechat},
            {name: '微信团购', icon: 'calculator',      color: 'orange', feature_module: :groupon} ],
          [ {name: '微信基础', icon: 'coffee',          color: 'green',  feature_module: :wechat_base}]
        ]
      end

      def dashboard_webpos_menus
        [
          [
            {name: '堂点', icon: 'coffee',           color:'blue', link: 'http://www.diandantong.com/download', feature_module: :eat_in_hall},
            {name: '预定', icon: 'pencil-square-o',  color:'yellow', link: 'http://www.diandantong.com/download', feature_module: :reservation},
          ],
          [
            {name: '快餐', icon: 'cutlery',          color:'blue', link: 'http://www.diandantong.com/download', feature_module: :fastfood},
            {name: '外卖', icon: 'motorcycle',       color:'orange', link: 'http://www.diandantong.com/download', feature_module: :delivery}
          ]

        ]
      end

    end
  end
end
