# encoding: utf-8
module Ddt
  module SystemMaterial
    class VipUser < ::Ddt::SystemMaterial::Base
      def build_message
        items = []
        if user.present?
          vip_info = user.vip_info
          content = "尊敬的#{shop.name}会员: \n\t用户ID:#{user.id}"
          if vip_info.present?
            content += "\n您的VIP信息如下："
            content += "\n\tVIP卡号: #{vip_info.vip_no}"
            content += "\n\tVIP级别: #{vip_info.vip_level.name}"
            content += "\n\tVip折扣: #{vip_info.vip_level.discount}"
            content += "\n\t余额: #{vip_info.card_wallet.display_amount}"
            content += "\n\t积分: #{vip_info.credits_wallet.display_amount}"
          end
          content += "\n您在本店的订单数#{user.placed_orders_count || 0 }笔"
          content += "\n累计消费#{vip_info.total_amount || 0}"

          items << {
            title: "以下是您的会员信息",
            description: content,
            url: Ddt::LinkResource.new(shop: shop).user_center_url,
            pic_url: shop.vip_logo_variant(:thumb)
          }
        else
          items << {title: "对不起，您尚未绑定用户身份，请点击本连接进行自动绑定", description: '猛戳这里 >> '}
        end
        response_news_msg(items)
      end
    end
  end
end
