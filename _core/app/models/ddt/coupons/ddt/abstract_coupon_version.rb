#encoding: utf-8
module Ddt
  #
  # 注意，部分的优惠券仅属于 Shop，故与Branch有关的关联不一定可用
  #
  class AbstractCouponVersion < Ddt::Base
    include Ddt::BelongsToShop
    include Discard::Model
    default_scope { kept }
    has_many :base_coupons, class_name: 'Ddt::BaseCoupon'
    has_many :coupon_usage_instructions, dependent: :destroy, class_name: 'Ddt::CouponUsageInstruction'
    has_many :coupon_photos, as: :owner, class_name: 'Ddt::CouponPhoto', inverse_of: :owner
    accepts_nested_attributes_for :coupon_photos, :allow_destroy => true
    accepts_nested_attributes_for :coupon_usage_instructions, :allow_destroy => true
    access_with_shop_time_zone :usable_starts_at, :usable_expires_at
    acts_as_type :expired_type, [:fixed_expired_time, :after_send_expired_time], %w[统一过期时间 领取后若干天过期]

    has_and_belongs_to_many :branches, join_table: 'ddt_abstract_coupon_versions_branches', class_name: 'Ddt::Branch', foreign_key: :abstract_coupon_version_id
    ids_string_for :branches

    ### validations
    validates :name, :description, presence: true
    validates :usable_starts_at, :usable_expires_at, presence: true, if: ->{ self.is_fixed_expired_time? }
    validates :usable_days_after_send, presence: true, if: ->{ self.is_after_send_expired_time? }
    validates :max_grant_limit, presence: true, :numericality => {only_integer: true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1000000}
    validates_associated :coupon_usage_instructions
    validates_associated :coupon_photos
    validate :expire_time_should_after_start

    scope :tuans, ->{ where(type: [Ddt::GrouponVersion, Ddt::VoucherVersion])}
    scope :tuans_on_sale, -> { tuans.where('sellable_starts_at < :t AND sellable_expires_at > :t', t: Time.now) }
    scope :show_on_index, -> { where(show_on_index: true)}
    scope :usable, -> { where('usable_starts_at IS NULL OR usable_starts_at < ?', Time.now).where('usable_expires_at IS NULL OR usable_expires_at > ?', Time.now)}

    belongs_to :branch, class_name: 'Ddt::Branch'
    has_many :zones, class_name: 'Ddt::Zone', through: :branch
    scope :in_zone, ->(zone_id) {
      zone = Zone.find(zone_id)
      incZones = Zone.of_ancestor(zone)
      joins(:zones).where(:ddt_zones => { id:incZones.map(&:id)}).uniq
    }
    
    ### callbacks
    before_save :set_usable_interval_nil

    def branch_names
      branches.map(&:name).join(",")
    end

    def sellable?
      (sellable_starts_at.present? && Time.now >= sellable_starts_at) &&
      (sellable_expires_at.present? && Time.now <= sellable_expires_at)
    end

    def expire_time_should_after_start
      self.errors.add(:usable_starts_at, I18n.t('expire time should after start')) if self.usable_starts_at.present? && self.usable_expires_at && (self.usable_starts_at > self.usable_expires_at)
    end

    def type_str
      self.class.type_str
    end

    def self.type_str
      self.name.demodulize.underscore.gsub('_version', '')
    end

    [:coupon, :groupon, :voucher].each do |coupon_type|
      define_method "is_#{coupon_type}?" do
        self.type_str.to_sym == coupon_type
      end
    end

    def to_text
      txt = []
      txt << name
      txt << "面值:    #{norminal_value}(满 #{coupon_min_usable_amount} 可用)"
      txt << "过期时间: #{usable_expires_at.strftime("%Y-%m-%d")}" if usable_expires_at.present?
      txt << description
      txt.join("\n")
    end

    def usable_expires_at_formated
      if usable_expires_at.present?
        usable_expires_at.strftime("%Y-%m-%d")
      end
    end

    def send_coupon_to_user(user, track_from, bought_from_order=nil)
      if can_receive_by?(user)
        self.send("#{type_str}s").create!({
          base_user: user,
          track_from: track_from,
          bought_from_order: bought_from_order
        })
      end
    end

    def can_receive_by?(base_user, num=1)
      if self.max_count_each_user.present?
        base_user.base_coupons.where(abstract_coupon_version_id: self.id).count + num <= self.max_count_each_user &&
        base_coupons_count + num <= max_grant_limit
      else
        base_coupons_count + num <= max_grant_limit
      end
    end

    private
    def self.ransackable_scopes(auth_object = nil)
      %w(in_zone)
    end

    def set_usable_interval_nil
      if is_after_send_expired_time?
        self.usable_starts_at = nil
        self.usable_expires_at = nil
      end
    end


  end
end
