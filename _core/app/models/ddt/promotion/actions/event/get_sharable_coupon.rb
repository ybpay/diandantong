# encoding:utf-8
module Ddt
  class Promotion
    module Actions
      module Event
        class GetSharableCoupon < Ddt::Promotion::Actions::Event::Base
          include Ddt::PromotionActionModelName
          belongs_to :coupon_version, class_name: 'Ddt::CouponVersion', foreign_key: :abstract_coupon_version_id
          preference :coupon_count, :integer, default: 10
          validates_presence_of :coupon_version, on: :update
          validates_numericality_of :preferred_coupon_count, :greater_than => 0

          def perform(promotable)
            user = promotable.user
            if user && self.abstract_coupon_version_id
              sharable_coupon = user.sharable_coupons.create!(abstract_coupon_version_id: self.abstract_coupon_version_id, count: self.preferred_coupon_count)
              # weixin notification
              sharable_coupon_url = sharable_coupon.weixin_show_url
              article_options = {
                title: "恭喜您获得了#{self.preferred_coupon_count}个优惠券红包,内含优惠券(#{self.coupon_version.try(:name)}), 赶快分享给好友吧.",
                description: "注意：该红包自己不能使用，只能分享给好友才能使用哦！为避免浪费，赶快分享到朋友圈吧...",
                url: sharable_coupon_url
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
