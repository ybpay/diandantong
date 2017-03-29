#encoding: utf-8
module Ddt
  module OrdersStatistic
    class OrderCountByYear < OrderCount
      attr_accessor :year, :time_interval_id
      hash_attrs({
          年份: :year,
          时间区间: :time_interval_id
       })

      def self.class_info
        {
          name: 'order_count_by_year',
          paginate: false,
          permit_params: [:branch_id, :year, :time_interval_id],
          label: '订单数(月)',
          sortable: true
        }
      end

      def initialize(options={})
        super
        initialize_year_params(options)
      end

      def year_collection
        y = Time.now.year
        y.downto(y-4).to_a.map{|y| [y, y]}
      end

      def group_by_column
        :paid_at_year
      end

      def group_alias
        :time
      end

      def labels
        (1..12).map{|i| "#{i}月"}
      end

      def keys
        (1..12).map{|i| "%02d"%i}
      end

      def filters
        [
          filter_branch(support_all: false),
          filter_year,
          filter_time_interval
        ]
      end

    end
  end
end
