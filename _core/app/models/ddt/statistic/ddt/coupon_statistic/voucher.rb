# encoding:utf-8
module Ddt
  module CouponStatistic
    class Voucher < CouponStatistic::Detail

      def self.class_info
        {
          name: 'voucher',
          paginate: true,
          permit_params: [:start_time, :end_time],
          label: '代金劵使用记录'
        }
      end

      def coupon_type
        'Ddt::Voucher'
      end
    end
  end
end
