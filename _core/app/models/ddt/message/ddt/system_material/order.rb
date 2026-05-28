# encoding: utf-8
module Ddt
  module SystemMaterial
    class Order < ::Ddt::SystemMaterial::Base
      def build_message
        items = []
        if user.present?
          orders = user.orders.by_type(["Ddt::DeliveryOrder", "Ddt::EatInHallOrder", "Ddt::ReservationOrder"]).limit(5)
          orders.each_with_index do |order, index|
            if index == 0
              pic_url = order.branch.rect_image_variant(:medium)
            else
              pic_url = order.branch.rect_image_variant(:thumb)
            end
            items << {title: "#{order.number} 金额:#{order.total} 时间：#{order.created_at.strftime('%Y-%m-%d')}", pic_url: pic_url, url: order_url(order)}
          end

          unless items.present?
            items << {title: "对不起，您尚未在本平台下单，欢迎下单哦"}
          end
        else
          items << {title: "对不起，您尚未绑定用户身份，请点击本连接进行自动绑定", description: '猛戳这里 >> '}
        end
        response_news_msg(items)
      end

      private
      def order_url(order)
        return Ddt::LinkResource.new(shop: shop).order_url(order)
      end
    end
  end
end
