#encoding: utf-8
module Ddt
  module OrdersStatistic
    class OrderCountByMonth < OrderCount
      attr_accessor :year, :month, :time_interval_id
      hash_attrs({
          年份: :year,
          月份: :month,
          时间区间: :time_interval_id
      })

      def self.class_info
        {
          name: 'order_count_by_month',
          paginate: false,
          permit_params: [:branch_id, :year, :month, :time_interval_id],
          default_params: this_month,
          label: '订单数(日)',
          sortable: true,
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        initialize_month_params(options)
      end

      def group_by_column
        :paid_at_month
      end

      def group_alias
        :time
      end

      def labels
        keys.map do |k|
          wday = Date.new(year, month, k.to_i).wday
          wlabel = Ddt::TimeUtil.week_label(wday)
          "#{'%02d' % month}-#{k}(#{wlabel})"
        end
      end

      def csv_labels
        keys.map do |k|
          wday = Date.new(year, month, k.split('-')[1].to_i).wday
          "#{k}"
        end
      end

      def keys
        (start_time.day..end_time.day).map do |day|
          "%02d" % day
        end
      end

      def filters
        [
          filter_branch(support_all: false),
          filter_year,
          filter_month,
          filter_time_interval
        ]
      end

    end
  end
end
