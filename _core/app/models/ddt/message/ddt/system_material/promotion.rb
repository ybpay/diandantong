# encoding: utf-8
module Ddt
  module SystemMaterial
    class Promotion < ::Ddt::SystemMaterial::Base
      def build_message
        items = []
        promotions =  shop.promotions_including_branch.active.limit(5)
        if promotions.present?
          items << {title: "全部促销活动", pic_url: shop.rect_image_variant(:medium), url: promotions_url}
          promotions.each do |promotion|
            items << {title: "#{promotion.name}", pic_url: promotion.image_variant(:thumb), url: promotion_url(promotion)}
          end

        else
            items << {title: "对不起，本平台尚未开展促销活动"}
        end
        response_news_msg(items)
      end

      private
      def promotion_url(promotion)
        return Ddt::LinkResource.new(shop: shop).promotion_url(promotion)
      end

      def promotions_url
        return Ddt::LinkResource.new(shop: shop).promotions_url
      end
    end
  end
end
