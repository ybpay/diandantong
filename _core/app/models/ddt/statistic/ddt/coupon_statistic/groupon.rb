# encoding:utf-8
module Ddt
  module CouponStatistic
    class Groupon < CouponStatistic::Detail

      def self.class_info
        {
          name: 'groupon',
          paginate: true,
          permit_params:[:start_time, :end_time],
          label: '团购券使用记录'
        }
      end

      def coupon_type
        'Ddt::Groupon'
      end
    end
  end
end