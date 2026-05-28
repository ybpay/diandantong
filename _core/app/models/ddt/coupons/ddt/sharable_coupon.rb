# encoding:utf-8
module Ddt
  class SharableCoupon < Ddt::Base
    include BelongsToShop
    belongs_to :base_user, class_name: 'Ddt::BaseUser'
    belongs_to :coupon_version, ->{with_discarded}, class_name: 'Ddt::CouponVersion', foreign_key: :abstract_coupon_version_id
    has_many :coupons, as: :source
    set_shop_from :base_user

    delegate :name, to: :coupon_version, prefix: true

    def receive_errors
      @receive_errors ||= ActiveModel::Errors.new(self)
    end

    def can_receive_by?(base_user)
      receive_errors[:base] << "该优惠劵已被删除." if self.coupon_version.deleted?
      receive_errors[:base] << "对不起，您自己不能领取自己分享的红包." if self.base_user == base_user
      receive_errors[:base] << "该红包您已经领取过了." if self.received_users.include?(base_user)
      receive_errors[:base] << "红包已被领取完毕." unless self.receive_count < self.count
      receive_errors[:base] << "超过最大领取限额." unless self.coupon_version.can_receive_by?(base_user)
      receive_errors.empty?
    end

    def receive_by(base_user)
      self.coupon_version.coupons.create!({
        base_user: base_user,
        source: self
      })
      self.increment!(:receive_count)
      sharable_coupon_url = self.weixin_show_url
      left_count = self.count - self.receive_count
      article_options = {
        title: "您的好友#{base_user.nickname || base_user.name}领取了一张优惠券.",
        description: "您的优惠券红包#{self.coupon_version.name}#{ left_count > 0 ? "还有#{left_count}张未领取" : "已全部抢光"}",
        url: sharable_coupon_url
      }
      self.shop.notify_to(self.base_user, article_options)
    end

    def received_users
      self.coupons.includes(:base_user).map(&:base_user)
    end

    def weixin_show_path
      "weixin/shops/#{self.shop_id}/my?_ng_path=/user/sharable_coupons/#{self.id}"
    end

    url_method_for :weixin_show

  end
end
