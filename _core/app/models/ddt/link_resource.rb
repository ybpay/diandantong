# encoding: utf-8
require 'cgi'
module Ddt
  class LinkResource
    attr_reader :shop, :branch, :querys, :shop_root_path, :ddt_host
    def initialize(args={})
      @shop = args[:shop]
      @branch = args[:branch]
      @querys = args[:querys]
      init_shop_prefix
    end

    # ------
    def shop_whole_urls
      format_links(_shop_links)
    end

    def shop_branches_by_tag_whole_urls(filters = {})
      format_links(shop_branches_by_tag_links(filters))
    end

    def shop_delivery_branches_by_tag_whole_urls(filters = {})
      format_links(shop_delivery_branches_by_tag_links(filters))
    end

    def branch_whole_urls
      format_links(branch_links)
    end

    def shop_branches_whole_url(query = {})
      full_url(ng_link_shop_branches(query))
    end

    def shop_delivery_branches_whole_url(query = {})
      full_url(ng_link_shop_delivery_branches(query))
    end

    def article_whole_url(article)
      full_url(ng_link_article(article))
    end

    def base_coupon_whole_url(base_coupon)
      full_url(ng_link_base_coupon(base_coupon))
    end

    def vip_info_whole_url
      full_url(ng_link_shop_user_center)
    end


    def shop_home_url
      full_url(ng_link_shop_home)
    end

    def branch_home_url
      full_url(ng_link_branch_home)
    end

    def order_url(order)
      full_url(ng_link_order(order))
    end

    def promotions_url
      full_url(ng_link_shop_promotions)
    end

    def promotion_url(promotion)
      full_url(ng_link_promotion(promotion))
    end

    def user_center_url
      full_url(ng_link_shop_user_center)
    end

    def user_vip_info_url
      full_url(ng_link_shop_user_vip_info)
    end
    def branch_delivery_url
      full_url(ng_link_branch_delivery)
    end
    def branch_reservation_url
      full_url(ng_link_branch_reservation)
    end
    def branch_queue_url
      full_url(ng_link_branch_queue)
    end
    def branch_fastfood_url
      full_url(ng_link_branch_fastfood)
    end
    def branch_payment_url
      full_url(ng_link_branch_pay_online)
    end

    # 以下链接格式都为 #/aaa/bbb...
    def _shop_links
      links = []
      links << link("平台首页", ng_link_shop_home)
      if shop.multi_branch?
        links << link("外卖门店", ng_link_shop_delivery_branches)
        links << link("最近门店", ng_link_shop_nearby_branch)
        links << link("全部门店", ng_link_shop_branches)
      else
        links << link("门店首页", ng_link_single_branch_home)
      end
      links << link("用户中心", ng_link_shop_user_center)
      links << link("会员充值", ng_link_recharge_products)
      links << link("会员付款码", ng_link_shop_user_scan_code)
      links << link("门店促销", ng_link_shop_promotions)
      links << link("团购", ng_link_shop_tuans)
      links << link("我的签到", ng_link_shop_sign_records)
      links << link("订单中心", ng_link_shop_order_center)
      links << link("券包中心", ng_link_shop_coupon_center)
      links << link("积分兑换", ng_link_shop_exchange_nav)
      links << link("我的分享", ng_link_shop_wechat_share_records)
      #links << link("门店入驻", ng_link_shop_mechant_apply) if shop.multi_branch?
      links
    end

    def shop_branches_by_tag_links(filters = {})
      links = []
      @shop.branch_tags.each do |branch_tag|
        if branch_tag.count > 0
          links << link(branch_tag.name, ng_link_shop_branches(filters.merge(branch_tag_id_eq: branch_tag.id)))
        end
      end
      links
    end

    def shop_delivery_branches_by_tag_links(filters = {})
      links = []
      @shop.branch_tags.each do |branch_tag|
        if branch_tag.count > 0
          links << link(branch_tag.name, ng_link_shop_delivery_branches(filters.merge(branch_tag_id_eq: branch_tag.id)))
        end
      end
      links
    end


    def branch_links
      links = []
      links << link("门店首页", ng_link_branch_home)
      links << link("预订", ng_link_branch_order_seat)
      links << link("外卖", ng_link_branch_delivery_list)
      links << link("快餐", ng_link_branch_fastfood)
      links << link("买单", ng_link_branch_pay_online)
      links << link("排号", ng_link_new_guest_queue)
      links
    end

    def ng_link_shop_home
      {page: 'main', url: "#/"}
    end
    def ng_link_single_branch_home
      {page: 'main', url: "#/branches/#{shop.branches.first.id}"}
    end
    def ng_link_shop_user_center
      {page: 'my', url: "#/user/profile"}
    end

    def ng_link_shop_user_vip_info
      {page: 'my', url: "#/user/vip-info"}
    end

    def ng_link_shop_promotions
      {page: 'main', url: "#/promotions"}
    end

    def ng_link_shop_tuans
      {page: 'cart', url: "#/tuans"}
    end

    def ng_link_recharge_products
      {page: 'cart', url: "#/branches/#{shop.abstract_branch.id}/orders/recharge/new"}
    end

    def ng_link_shop_user_scan_code
      {page: 'my', url: '#/user/scan-code'}
    end

    def ng_link_shop_sign_records
      {page: 'my', url: '#/sign_records'}
    end

    def ng_link_shop_order_center
      {page: 'order', url: '#/orders/nav'}
    end

    def ng_link_shop_coupon_center
      {page: 'my', url: '#/user/coupon_nav'}
    end

    def ng_link_shop_wechat_share_records
      {page: 'my', url: '#/wechat_share_records'}
    end

    def ng_link_shop_exchange_nav
      {page: 'my', url: '#/user/exchange/nav'}
    end

    def ng_link_shop_mechant_apply
      {page: 'main', url: '#/merchant_apply'}
    end

    def ng_link_shop_nearby_branch
      {page: 'main', url: '#/nearby_branch'}
    end

    def ng_link_promotion(promotion)
      {page: 'main', url: "#/promotions/#{promotion.id}"}
    end

    def ng_link_order(order)
      {page: 'order', url: "#/branches/#{order.branch_id}/orders/#{order.type.demodulize.underscore.gsub("_order",'')}/#{order.id}"}
    end

    def ng_link_shop_delivery_branches(query={})
      {page: 'main', url: "#/delivery_branches?#{query.collect {|k,v|"_ng_query[#{k}]=#{URI.encode(v.to_s)}"}.join('&')}"}
    end

    def ng_link_shop_branches(query={})
      {page: 'main', url: "#/branches?#{query.collect {|k,v|"_ng_query[#{k}]=#{URI.encode(v.to_s)}"}.join('&')}"}
    end

    def ng_link_article(article)
      {page: 'main', url: "#/articles/#{article.id}"}
    end

    def ng_link_base_coupon(base_coupon)
      {page: 'my', url: "#/user/#{base_coupon.type.demodulize.underscore.pluralize}/#{base_coupon.id}"}
    end

    def ng_link_branch_home
      {page: 'main', url: "#/branches/#{branch.id}"}
    end
    def ng_link_branch_delivery_list
      {page: 'cart', url: "#/branches/#{branch.id}/products/delivery"}
    end
    def ng_link_branch_order_seat
      {page: 'cart', url: "#/branches/#{branch.id}/reservation_time_points"}
    end
    def ng_link_branch_delivery
      {page: 'cart', url: "#/branches/#{branch.id}/products/delivery"}
    end
    def ng_link_branch_reservation
      {page: 'cart', url: "#/branches/#{branch.id}/reservation_time_points"}
    end
    def ng_link_branch_queue
      {page: 'queue', url: "#/branches/#{branch.id}/guest_queue"}
    end
    def ng_link_branch_pay_online
      {page: 'cart', url: "#/branches/#{branch.id}/pay_online"}
    end
    def ng_link_new_guest_queue
      {page: 'queue', url: "#/branches/#{branch.id}/guest_queues/new_guest"}
    end
    def ng_link_branch_fastfood
      {page: 'cart', url: "#/branches/#{branch.id}/products/fastfood"}
    end

    private

    def link(name, ng_link)
      {name: name, ng_link: ng_link}
    end

    def format_links(links)
      links.map{|l| format_link(l)}
    end

    def format_link(_link)
      _link[:url] = full_url(_link[:ng_link])
      _link
    end

    def full_url(ng_path)
      URI.join(ddt_host, url_prefix(ng_path[:page]) + prefix_ng_path(ng_path[:url])).to_s
    end

    def url_prefix(page='main')
      shop_root_path + "/#{page}" + source_from_weixin + ext_querys
    end

    def init_shop_prefix
      @shop_root_path = Ddt::Core::Engine.routes.url_helpers.weixin_shop_path(shop.id) if shop.present?
      @ddt_host = Rails.application.routes.url_helpers.ddt_url
    end

    def prefix_ng_path(ng_url)
      url = ng_url.start_with?('#') ? ng_url[1..-1] : ng_url
      '&_ng_path=' + CGI::escape(url.encode(Encoding::GBK))
    end

    def source_from_weixin
      "?source=mp.weixin.qq.com"
    end

    def ext_querys
      if querys.present?
        "&#{querys.to_query}"
      else
        ""
      end
    end

  end
end
