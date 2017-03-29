module Ddt
  module CouponStatistic
    class CouponSummary < CouponStatistic::Summary

      def self.class_info
        {
          name: 'coupon_summary',
          paginate: false,
          permit_params: [:start_time, :end_time, :coupon_version_id],
          label: '优惠券使用统计',
          sortable: true
        }
      end

      def coupon_type
        'Ddt::Coupon'
      end

      def filters
        [
          { name: 'version_id', type: 'collection', collection: shop.coupon_versions.with_deleted, prompt: '选择优惠券'},
          filter_start_time,
          filter_end_time
        ]
      end

    end
  end
end
