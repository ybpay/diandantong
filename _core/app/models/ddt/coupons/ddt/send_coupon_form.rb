module Ddt
  class SendCouponForm
    include ActiveModel::Validations
    attr_accessor :coupon_version_id, :count, :base_user_ids, :shop

    validates_presence_of :coupon_version_id, :count, :base_user_ids
    validates_numericality_of :count, :greater_than => 0, :less_than_or_equal_to => 10

    def initialize(hash = {})
      hash.each do |key, value|
        self.send(:"#{key}=", value)
      end
    end

    def self.human_attribute_name(attribute, options={})
      {
        coupon_version_id: "优惠券",
        count: "数量"
      }[attribute.to_sym] || super
    end

    def to_key
      nil
    end

    def perform
      Ddt::SendCoupon.new(
        shop_id: shop.id,
        coupon_version_id: coupon_version_id,
        count: count,
        to_user_ids: base_user_ids.split(",")
      ).perform
    end

  end
end
