module Ddt
  module CouponStatistic
    class GrouponSummary < CouponStatistic::Summary

      def self.class_info
        {
          name: 'groupon_summary',
          paginate: false,
          permit_params: [:start_time, :end_time, :coupon_version_id],
          label: '团购券使用统计',
          sortable: true
        }
      end

      def coupon_type
        'Ddt::Groupon'
      end

      def filters
        [
          { name: 'version_id', type: 'collection', collection: shop.groupon_versions.with_deleted, prompt: '选择团购券'},
          filter_start_time,
          filter_end_time
        ]
      end

    end
  end
end
