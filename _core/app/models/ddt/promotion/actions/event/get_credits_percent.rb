#encoding: utf-8
module Ddt
  class Promotion
    module Actions
      module Event
        class GetCreditsPercent < Ddt::Promotion::Actions::Event::Base
          include Ddt::PromotionActionModelName
          preference :percent   , :integer , default: 100
          validates_numericality_of :preferred_percent, :greater_than => 0

          def applicable?(promotable)
            promotable.is_a?(Ddt::Promotion::Events::OrderPay) && !promotable.order.is_recharge?
          end

          def perform(promotable)
            return unless applicable?(promotable)
            user = promotable.user
            vip = user.try(:vip_info) || promotable.try(:order).try(:current_vip)
            if vip
              order = promotable.order
              amount = (order.total - order.pay_items.vip_card_pay.pay_item_total) * 1.0 * self.preferred_percent / 100
              vip.credits_wallet.get(amount, note: promotion.name)
              if user
                promotion_url = self.promotion.weixin_show_url
                article_options = {
                  title: "恭喜您获得了#{amount}积分",
                  description: "来自免赠促销:#{self.promotion.name}",
                  url: promotion_url
                }
                user.shop.notify_to(user, article_options)
              end
            end
            super
          end

          def label
            "#{I18n.t(:promotion)} (#{promotion.name})"
          end
        end
      end
    end
  end
end
