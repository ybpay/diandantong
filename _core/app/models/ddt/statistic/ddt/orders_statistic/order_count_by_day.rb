#encoding: utf-8
module Ddt
  module OrdersStatistic
    class OrderCountByDay < OrderCount
      attr_accessor :date
      hash_attrs({
          日期: :date
     })

      def self.class_info
        {
          name: 'order_count_by_day',
          paginate: false,
          permit_params: [:branch_id, :date],
          default: this_day,
          label: '订单数(时)',
          sortable: true,
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        initialize_day_params(options)
      end

      def group_by_column
        :paid_at_hour
      end

      def group_alias
        :time
      end


      def keys
        (0..23).map do |hour|
          "%02d" % hour
        end
      end

      def labels
        (0..23).map do |hour|
          "%02d:00~%02d:00" % [hour, hour+1]
        end
      end

      def filters
        [
          filter_branch(support_all: false),
          filter_date
        ]
      end

    end
  end
end
