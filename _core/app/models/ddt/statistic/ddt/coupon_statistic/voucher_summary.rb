
module Ddt
  module CouponStatistic
    class VoucherSummary < CouponStatistic::Summary

      def self.class_info
        {
          name: 'voucher_summary',
          paginate: false,
          permit_params: [:start_time, :end_time, :voucher_version_id],
          label: '代金券使用统计',
          sortable: true
        }
      end

      def coupon_type
        'Ddt::Voucher'
      end

      def filters
        [
          { name: 'version_id', type: 'collection', collection: shop.voucher_versions.with_discarded, prompt: '选择代金券'},
          filter_start_time,
          filter_end_time
        ]
      end

    end
  end
end
