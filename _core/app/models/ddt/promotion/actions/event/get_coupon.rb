# encoding:utf-8
module Ddt
  class Promotion
    module Actions
      module Event
        class GetCoupon < Ddt::Promotion::Actions::Event::Base
          include Ddt::PromotionActionModelName
          belongs_to :coupon_version, class_name: 'Ddt::CouponVersion', foreign_key: :abstract_coupon_version_id
          validates_presence_of :coupon_version, on: :update

          def perform(promotable)
            user = promotable.user
            # 只有在user存在并且coupon_version也存在的情况下才发放优惠券
            if user.present? && self.coupon_version.present?
              Ddt::BaseCoupon.notify = false
              self.coupon_version.send_coupon_to_user(user, :promotion)
              # weixin notification
              coupons_url = URI.join(Rails.application.routes.url_helpers.ddt_url, "weixin/shops/#{self.shop_id}/my?_ng_path=/user/coupons").to_s
              article_options = {
                title: "恭喜您获得了一张优惠券(#{self.coupon_version.name})",
                description: "该奖品是由免赠促销活动#{self.promotion.name}所发放",
                url: coupons_url
              }
              user.shop.notify_to(user, article_options)
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
