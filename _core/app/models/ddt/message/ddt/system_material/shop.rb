# encoding: utf-8
module Ddt
  module SystemMaterial
    class Shop < ::Ddt::SystemMaterial::Base
      include ActiveSupport::NumberHelper
      def build_message
        items = []
        branches = shop.active_branches_in_distance(user)
        if branches.any? and shop.is_multi_branches?
          if wechat_account.default_branch.present?
            default_branch = wechat_account.default_branch
            content = "欢迎关注#{default_branch.name}，点击进入"
            items << { title: content, description: default_branch.introduction_decoder, pic_url: default_branch.rect_image_variant(:medium), url: branch_url(default_branch) }
          else
            content = "欢迎关注#{shop.name}，点击进入"
            items << { title: content, description: '直接进入门店列表'}
            branches[0..4].each do |branch|
              distance = number_to_human(branch.distance_of(user), units: 'distance', strip_insignificant_zeros: true)
              distance_text = " (约 #{distance})" if distance.present?
              items << { title: "#{branch.name}#{distance_text}", description: branch.introduction_decoder, pic_url: branch.image_variant(:thumb), url: branch_url(branch) }
            end
          end
        elsif branches.any?
          items = single_shop_message(branches.first)
        else
          content = "该账号没有运营的门店"
          items << { title: content, description: "直接进入门店列表", pic_url: shop.rect_image_variant(:medium) }
        end
        response_news_msg(items)
      end

      def single_shop_message(branch)
        branch_type = branch.branch_type
        items = []
        content = "欢迎关注#{shop.name}"
        items << { title: content, description: (shop.introduction_decoder||branch.introduction_decoder), pic_url: shop.rect_image_variant(:medium) }
        links = Ddt::LinkResource.new(shop: shop, branch: branch)
        items << { title: "预订", url: links.branch_reservation_url, pic_url: branch_type.reservation_img_variant(:thumb)} if branch.use_reservation_setting
        items << { title: "点餐", url: links.shop_home_url, pic_url: branch_type.order_in_seat_img_variant(:thumb)} if branch.use_eat_in_hall_setting
        items << { title: "外卖", url: links.branch_delivery_url, pic_url: branch_type.delivery_img_variant(:thumb)} if branch.use_delivery_setting
        items << { title: "排队", url: links.branch_queue_url, pic_url: branch_type.queue_img_variant(:thumb)} if branch.use_queue_setting
        items
      end
    end
  end
end
