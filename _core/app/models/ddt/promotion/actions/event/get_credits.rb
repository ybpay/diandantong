#encoding: utf-8
module Ddt
  class Promotion
    module Actions
      module Event
        class GetCredits < Ddt::Promotion::Actions::Event::Base
          include Ddt::PromotionActionModelName
          preference :credits   , :integer , default: 10
          validates_numericality_of :preferred_credits, :greater_than => 0, :less_than => MAX_INTEGER

          def perform(promotable)
            user = promotable.user
            vip = user.try(:vip_info) || promotable.try(:order).try(:current_vip)
            if vip
              vip.credits_wallet.get(self.preferred_credits, note: promotion.name)
              if user
                promotion_url = self.promotion.weixin_show_url
                article_options = {
                  title: "恭喜您获得了#{self.preferred_credits}积分",
                  description: "该奖品是由免赠促销活动#{self.promotion.name}所发放",
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
