#encoding: utf-8
module Ddt
  module OrdersStatistic
    class OrderCountByBranch < OrderCount
      attr_accessor :year, :month, :time_interval_id
      hash_attrs({
          年份: :year,
          月份: :month,
          时间区间: :time_interval_id,
          管理门店: Proc.new{@accessible_branches.try(:map, &:id)},
      })

      def self.class_info
        {
          管理门店: Proc.new{@accessible_branches.try(:map, &:id)},
          name: 'order_count_by_branch',
          paginate: false,
          permit_params: [:year, :month, :time_interval_id],
          default_params: this_month,
          label: '订单数(按店)',
          sortable: true,
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        initialize_month_params(options)
        @branch_id = ALL_BRANCH
      end

      def title
        %W[门店 消费总额 折扣金额 销售金额 订单数 客人数 单均 人均]
      end

      def group_by_column
        :branch_id
      end

      def group_alias
        :branch_id
      end

      def labels
        accessible_branches.map(&:name)
      end

      def csv_labels
        labels
      end

      def keys
        accessible_branches.map(&:id)
      end

      def filters
        [
          filter_year,
          filter_month,
          filter_time_interval
        ]
      end

      def to_combi_result
        result
      end

      def query
        return [] if branch_id.blank?
        params = {
            query: {
                shop_id_eq: shop.id,
                type_in: Ddt::OrderService::Order::Base.base_types
            },
            group_by: group_by_column,
            where: time_interval_clause
        }
        params[:query][:branch_id_eq] = branch_id if one_branch?

        query = params[:query]

        @items = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:branch_id],
            accumulate_keys: [:adjustment_total, :total, :guest_num, :times]
        ) do |current_date, next_date, has_next|
          query[:paid_at_gteq] = current_date
          if (has_next)
            query[:paid_at_lt] = next_date
          else
            query.delete(:paid_at_lt)
            query[:paid_at_lteq] = next_date
          end
          Ddt::OrderService::Api::Statistic.order_times_total(params).map{|line_item|
            {
              times:                  line_item.times,
              total:                  line_item.total,
              adjustment_total:       line_item.adjustment_total,
              guest_num:              line_item.guest_num,
              branch_id:              line_item.branch_id
            }
          }
        end
      end

    end
  end
end
