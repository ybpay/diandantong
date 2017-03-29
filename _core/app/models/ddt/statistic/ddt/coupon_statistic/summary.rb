# encoding: utf-8
module Ddt
  module CouponStatistic
    class Summary < ::Ddt::CouponStatistic::Base
      include Ddt::CacheModel
      cache_model 'Ddt::Branch', with_deleted: true
      cache_model 'Ddt::AbstractCouponVersion', with_deleted: true
      attr_accessor :version_id
      hash_attrs({
          版本: :version_id
      })

      def initialize(options={})
        super
        @version_id  = options[:version_id]
      end

      def coupon_type
        'Ddt::Coupon'
      end

      def applied
        @applied ||= shop.base_coupons.ransack({
          type_eq: coupon_type,
          abstract_coupon_version_id_eq: version_id,
          applied_at_gteq: start_time,
          applied_at_lteq: end_time,
        }).result
      end

      def send_out_count
        @send_out ||= shop.base_coupons.ransack({
          type_eq: coupon_type,
          abstract_coupon_version_id_eq: version_id,
          created_at_gteq: start_time,
          created_at_lteq: end_time
        }).result.count
      end

      def title
        %w[门店 使用数 金额 占使用总量比率 使用率]
      end

      def body
        items = applied
        total = sum_of_items(items)
        summary = items.group_by(&:applied_in_branch_id)
        content = []
        summary.each do |branch_id, items|
          first = items[0]
          branch = get_branch(first.applied_in_branch_id)
          version = get_version(first.abstract_coupon_version_id)
          scope_name = branch.nil? ? '平台' : branch.name
          content << [
            scope_name,
            items.count,
            sum_of_items(items),
            rate_label(sum_of_items(items), total),
            rate_label(items.count, send_out_count) + ", 总发放量(#{send_out_count})"
          ]
        end
        content
      end

      def sum_of_items(items)
        items.map do |item|
          version = get_version(item.abstract_coupon_version_id)
          version.norminal_value || 0
        end.sum
      end

      def get_version(version_id)
        get_abstract_coupon_version(version_id)
      end

    end
  end
end
