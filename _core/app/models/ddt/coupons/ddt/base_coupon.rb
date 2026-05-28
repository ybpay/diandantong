# encoding:utf-8
module Ddt
  class BaseCoupon < Ddt::Base
    include Ddt::BelongsToShop
    include Exchangeable
    belongs_to :operator, polymorphic: true
    before_create :set_refund_msg
    before_create :set_applied_in_branch_id
    after_create :create_exchange_code
    # after_create :send_notify_to_user
    belongs_to :base_user, class_name: 'Ddt::BaseUser'
    alias_method :user, :base_user
    belongs_to :abstract_coupon_version, ->{with_discarded}, class_name: 'Ddt::AbstractCouponVersion', foreign_key: :abstract_coupon_version_id,  counter_cache: true
    belongs_to_order name: :bought_from_order
    belongs_to_order name: :applied_to_order
    belongs_to :source, polymorphic: true # sharable_coupon
    validates_presence_of :expires_at, :base_user, :abstract_coupon_version
    scope :coupon,  ->{ where(type: Ddt::Coupon)}
    scope :groupon, ->{ where(type: Ddt::Groupon)}
    scope :voucher, ->{ where(type: Ddt::Voucher)}
    scope :is_expired, ->(bool=true){
      if [true, 'true'].include?(bool)
        where("ddt_base_coupons.expires_at < ?", Time.now)
      else
        where("ddt_base_coupons.expires_at > ?", Time.now)
      end
    }
    scope :not_expired,->{ where("ddt_base_coupons.expires_at > ?", Time.now)}
    scope :expired, -> { where("ddt_base_coupons.expires_at < ?", Time.now)}
    scope :applied, ->{ where.not(applied_at: nil)}
    scope :actived, ->{ where("ddt_base_coupons.usable_starts_at is null or ddt_base_coupons.usable_starts_at < ?", Time.now)}
    scope :not_applied, ->{ where(applied_at: nil)}
    scope :refund, -> { where.not(refund_at: nil)}
    scope :not_refund, -> { where(refund_at: nil)}
    scope :available,->{ not_applied.not_expired.not_refund }
    before_validation :set_times

    set_from :abstract_coupon_version
    acts_as_type :track_from, %W(credit promotion system order), %W(积分兑换 活动发放 系统发放 订单购买)

    def self.ransackable_scopes(auth_object = nil)
      %w(expired is_expired)
    end

    def usable?
      ( usable_starts_at.present? && Time.now >= usable_starts_at) &&
      (usable_expires_at.present? && Time.now <= usable_expires_at)
    end

    def rollback_coupon
      throw Exception #取消订单时取消优惠券,在子类实现
    end

    def applied?
      self.applied_at.present?
    end

    def expired?
      self.expires_at < Time.now
    end

    def self.notify=(flag)
      RequestStore.store[:_base_coupon_notify] = flag
    end

    def self.notify?
      RequestStore.store[:_base_coupon_notify]
    end

    def send_notify_to_user
      if Ddt::BaseCoupon.notify?
        if user.type == "Ddt::User"
          self.shop.notify_to(user, {
            title: "恭喜您，获得一张#{coupon_type_name}!",
            description: "#{abstract_coupon_version.to_text}",
            url: Ddt::LinkResource.new(shop: self.shop).base_coupon_whole_url(self)
          })
        end
      end
      self.class.notify = true
    end

    def type_str
      self.class.name.demodulize.underscore
    end

    def coupon_type_name
      case type
      when "Ddt::Coupon"  then "优惠券"
      when "Ddt::Groupon" then "团购券"
      when "Ddt::Voucher" then "代金券"
      end
    end

    def backend_show_path
      "/backend/shops/#{self.shop.slug}/#{type_str.pluralize}"
    end

    def set_times
      set_expires_at
      version = self.abstract_coupon_version
      self.usable_starts_at = version.usable_starts_at
      self.usable_expires_at = version.usable_expires_at
    end

    def set_expires_at
      if self.expires_at.blank? && self.abstract_coupon_version.present?
        self.expires_at = self.abstract_coupon_version.usable_expires_at
      end
    end

    def set_refund_msg
      self.support_refund = self.abstract_coupon_version.support_refund
      self.refundable_days_after_send = self.abstract_coupon_version.refundable_days_after_send
    end

    def set_applied_in_branch_id
      if self.applied_to_order.present?
        self.applied_in_branch_id = self.applied_to_order.branch_id
      end
    end

  end
end
