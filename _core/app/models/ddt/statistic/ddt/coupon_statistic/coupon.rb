# encoding:utf-8
module Ddt
  module CouponStatistic
    class Coupon < CouponStatistic::Detail

      def self.class_info
        {
          name: 'coupon',
          paginate: true,
          permit_params:[:start_time, :end_time],
          label: '优惠券使用记录'
        }
      end

      def coupon_type
        'Ddt::Coupon'
      end
    end
  end
end
