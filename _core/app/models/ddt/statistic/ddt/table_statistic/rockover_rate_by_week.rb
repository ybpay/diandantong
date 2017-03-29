#encoding: utf-8
module Ddt
  module TableStatistic
    class RockoverRateByWeek < TableStatistic::RockoverRate
      attr_accessor :week
      hash_attrs({
          周: :week
      })

      def self.class_info
        {
          name: 'rockover_rate_by_week',
          paginate: false,
          permit_params: [:branch_id, :week],
          default_params: this_week,
          label: '翻台率(周平均)',
          sortable: true,
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        initialize_week_params(options)
      end

      def filters
        [
          filter_week
        ]
      end

      def title
        %W[门店 桌台数 餐位数 交易数 开台数 客人数 上座率 开台率 翻台率]
      end

      def body
        items = result
        content = []
        items.each do |item|
          branch_name = get_branch_name(item[:branch_id])
          branch_tables = get_branch_tables(item[:branch_id])
          table_count = branch_tables.count
          seat_count = sum(branch_tables, :capacity)
          order_times = (item[:times] || 0)
          guest_num = (item[:guest_num] || 0)
          content << [
            branch_name,
            table_count,
            seat_count,
            order_times,
            order_times,
            guest_num,
            rate_label(guest_num, (meal_num * 7 * seat_count)),
            rate_label(order_times, (meal_num * 7 * table_count)),
            rockover_rate(order_times, (meal_num * 7 * table_count))
          ]
        end
        content
      end

    end
  end
end
