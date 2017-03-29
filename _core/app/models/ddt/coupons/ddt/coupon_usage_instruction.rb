module Ddt
  class CouponUsageInstruction < Ddt::Base
    replicated_model

    belongs_to :abstract_coupon_version, class_name: 'Ddt::AbstractCouponVersion'
    validates_presence_of :content
  end
end
