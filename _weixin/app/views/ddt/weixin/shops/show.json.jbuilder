json.cache! [@current_shop], expires_in: 1.day do
  json.extract! @current_shop, :id, :name, :slug, :is_open, :expiration_time, :telephone, :service_email, :sina_weibo,
  :hide_support_brand, :enable_foreign, :foreign_currency_symbol, :foreign_time_zone, :currency, :placed_orders_count, :shop_type, :features,
  :introduction, :enable_vip_info_phone_validation
  json.use_validation_sms  @current_shop.can_use_validation_sms?
  json.use_sms @current_shop.use_sms?
  json.vip_logo @current_shop.vip_logo.thumb.url
  json.is_support_alipay    @current_shop.current_alipay_method.present?
  json.is_support_wechatpay @current_shop.current_wechatpay_method.present?
  json.is_support_baidupay @current_shop.current_baidupay_method.present?
  json.app_id @current_shop.primary_wechat_account.try(:account_appid)
  json.has_vip_level @current_shop.vip_levels.present?
  json.abstract_branch_id @current_shop.abstract_branch.id
  json.debug @current_shop.debug
  json.image @current_shop.image.url
  json.rect_image @current_shop.rect_image.url
  json.credits_exchange_radio @current_shop.credits_setting.exchange_radio

  unless @current_shop.hide_support_brand?
    json.extract! @current_shop, :support_brand_name, :support_telephone, :support_wechat_introduce_url, :support_brand_link
  end

  json.branch_types @current_shop.branch_types.includes(:branches) do |branch_type|
    json.extract! branch_type, :id, :name, :icon, :bg_color, :branch_ids,
        :show_reservation_img, :reservation_img_text,
        :show_order_in_seat_img, :order_in_seat_img_text,
        :show_delivery_img, :delivery_img_text,
        :show_fastfood_img, :fastfood_img_text,
        :show_queue_img, :queue_img_text,
        :show_pay_online_img, :pay_online_img_text,
        :show_wifi, :show_parking

      json.reservation_img branch_type.reservation_img.mini.url
      json.order_in_seat_img branch_type.order_in_seat_img.mini.url
      json.delivery_img branch_type.delivery_img.mini.url
      json.fastfood_img branch_type.fastfood_img.mini.url
      json.queue_img branch_type.queue_img.mini.url
      json.pay_online_img branch_type.pay_online_img.mini.url
    json.image branch_type.image.thumb.url if branch_type.image
  end


  json.branch_sliders @current_shop.branch_sliders do |branch_slider|
    json.extract! branch_slider, :id, :url
    json.img branch_slider.img.medium.url
  end

  json.cache! [@current_shop.custom_weixin_info], expires_in: 1.day do
    json.custom_weixin_info do
      json.extract! @current_shop.custom_weixin_info, :layout_type, :branch_index_layout
      json.background_image @current_shop.custom_weixin_info.background_image.medium.url
      json.home_hot_links @current_shop.custom_weixin_info.home_hot_links.where(is_multiple: @current_shop.is_multi_branches?) do |home_hot_link|
        json.extract! home_hot_link, :icon, :icon_background_color, :link, :label
        json.image home_hot_link.image.thumb.url if home_hot_link.image.url.present?
      end
      json.home_usable_links @current_shop.custom_weixin_info.home_usable_links do |home_usable_link|
        json.extract! home_usable_link, :title, :keywords, :link
        json.image home_usable_link.image.thumb.url if home_usable_link.image.url.present?
      end
    end
  end

  json.is_single @current_shop.single_branch?

  if @current_shop.single_branch? && @current_shop.branches.present?
    default_branch = @current_shop.branches.first
    default_branch_type = default_branch.branch_type
    json.default_branch_id default_branch.id
    json.single_branch_links do
      if default_branch.use_reservation_setting
        json.child! {
          json.label default_branch_type.reservation_img_text.presence||'预订'
          json.icon 'fa-dot-circle-o'
          json.icon_color '#fff'
          json.icon_background_color '#fb5855'
          json.link Ddt::LinkResource.new(shop: @current_shop, branch: default_branch).branch_reservation_url
          json.image default_branch_type.reservation_img.mini.url
        }
      end
      if default_branch.use_eat_in_hall_setting
        json.child! {
          json.label default_branch_type.order_in_seat_img_text.presence||'点菜'
          json.icon 'fa-cutlery'
          json.icon_color '#fff'
          json.icon_background_color '#ffa321'
          json.link "#/branches/#{default_branch.id}/eat_in_hall"
          json.image default_branch_type.order_in_seat_img.mini.url
        }
      end
      if default_branch.use_delivery_setting
        json.child! {
          json.label default_branch_type.delivery_img_text.presence||'外卖'
          json.icon 'fa-truck'
          json.icon_color '#fff'
          json.icon_background_color '#28a267'
          json.link Ddt::LinkResource.new(shop: @current_shop, branch: default_branch).branch_delivery_url
          json.image default_branch_type.delivery_img.mini.url
        }
      end
      if default_branch.use_queue_setting
        json.child! {
          json.label default_branch_type.queue_img_text.presence||'排队'
          json.icon 'fa-weixin'
          json.icon_color '#fff'
          json.icon_background_color '#ff7994'
          json.link Ddt::LinkResource.new(shop: @current_shop, branch: default_branch).branch_queue_url
          json.image default_branch_type.queue_img.mini.url
        }
      end
      if default_branch.use_pay_online_setting
        json.child! {
          json.label default_branch_type.pay_online_img_text.presence||'买单'
          json.icon 'fa-cc-visa'
          json.icon_color '#fff'
          json.icon_background_color '#34afbe'
          json.link Ddt::LinkResource.new(shop: @current_shop, branch: default_branch).branch_payment_url
          "#/branches/#{default_branch.id}/pay_online"
          json.image default_branch_type.pay_online_img.mini.url
        }
      end
    end
  end
  json.has_tutorial @one_pages.present?

  if @current_shop.has_feature?(:base_event_promotion)
    json.promotions_show_on_index @current_shop.promotions_including_branch.of_show_on_index.active do |promotion|
      json.extract! promotion, :id, :name, :keywords, :starts_at, :expires_at, :description
      json.image promotion.image.thumb.url
    end
  else
    json.promotions_show_on_index []
  end

  if @current_shop.has_feature?(:base_groupon)
    json.tuans_show_on_index @current_shop.abstract_coupon_versions.tuans_on_sale.show_on_index do |tuan|
      json.extract! tuan, :id, :name, :name_with_items, :usable_starts_at, :usable_expires_at, :description, :groupon_price
      json.image tuan.coupon_photos.first.try(:image).try(:thumb_square).try(:url)
    end
  else
    json.tuans_show_on_index []
  end
end

if @current_wechat_account.present? && @current_wechat_account.default_branch
  json.default_branch_id @current_wechat_account.default_branch_id
end


# 否则，检查用户是否关注过公众号
unless @current_user.wifi_code
  json.wechat_account do
    if !@current_shop.is_set_as_third_part_url or is_follow_wechat_account?
      json.is_followed true
    else
      json.is_followed false
      wechat_account = @current_wechat_account || @current_shop.primary_wechat_account
      if wechat_account.present?
        json.account_name wechat_account.account_name
        json.weixin_hao wechat_account.weixin_hao
        json.qrcode "http://open.weixin.qq.com/qr/code/?username=#{wechat_account.gonghao_open_id}"
      end
    end
  end
end
