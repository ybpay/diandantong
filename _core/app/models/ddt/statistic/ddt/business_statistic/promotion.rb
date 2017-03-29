# encoding:utf-8
module Ddt
  module BusinessStatistic
    class Promotion < ::Ddt::BusinessStatistic::Base
      attr_accessor :branch_name, :privilege_promotion, :order_promotion, :base_coupon
      hash_attrs({
        管理门店: Proc.new{@accessible_branches.try(:map, &:id)},
      })

      def self.class_info
        {
          name: 'promotion',
          paginate: false,
          permit_params: [:branch_id, :start_time, :end_time],
          default_params: today,
          label: '优惠折扣',
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        if @start_time.blank? || @end_time.blank?
          @start_time = now.beginning_of_day
          @end_time = now.end_of_day
        end
      end

      def adjustment_reasons
        Ddt::OrderService::Adjustment.discount_reasons
      end

      def result
        #TODO: split by time
        return @result if @result.present?
        query_params = {
          created_at_gteq: start_time,
          created_at_lteq: end_time,
          reason_in: adjustment_reasons
        }
        if @branch_id.present?
          query_params[:branch_id_eq] = branch_id
        else
          query_params[:branch_id_in] = accessible_branches.map(&:id)
        end

        @result ||= Ddt::OrderService::Api::Statistic.adjustment_amount(query: query_params,
          group_by: [:"ddt_adjustments.branch_id", :reason]
        )
        @result
      end
      cache_result

      def filters
        [
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        %W(门店 权限折扣 权限减免 权限免单 优惠券优惠 代金券优惠 促销优惠 赠菜 会员价 会员折扣 积分抵扣 余额抵扣 折扣方案 其他 合计)
      end

      def body
        adjustments = result
        content = []
        accessible_branches.each do |branch|
          row = []
          row << branch.name
          adjustment_reasons.each do |reason|
            amount = (adjustments[branch.id][reason] rescue 0)
            row << (amount.present? ? amount : 0)
          end
          row << row[1, row.size-1].sum
          content << row
        end
        content
      end

      def to_combi_result
        adjustments = result
        h = {}
        accessible_branches.each do |branch|
          detail = {}
          detail[:branch_id] = branch.id
          detail[:branch_name] = branch.name
          detail[:adjustment] = (adjustments[branch.id].values.sum rescue 0)
          h[branch.id] = detail
        end
        h
      end

    end
  end
end
