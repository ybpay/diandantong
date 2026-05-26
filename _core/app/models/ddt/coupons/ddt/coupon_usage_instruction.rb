module Ddt
  class CouponUsageInstruction < Ddt::Base

    belongs_to :abstract_coupon_version, class_name: 'Ddt::AbstractCouponVersion'
    validates_presence_of :content
  end
end
