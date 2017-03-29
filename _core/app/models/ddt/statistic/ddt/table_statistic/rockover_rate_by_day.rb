#encoding: utf-8
module Ddt
  module TableStatistic
    class RockoverRateByDay < RockoverRate
      attr_accessor :date
      hash_attrs({
          日期: :date
     })


      def self.class_info
        {
          name: 'rockover_rate_by_day',
          paginate: false,
          permit_params: [:branch_id, :date],
          default_params: this_day,
          label: '翻台率',
          sortable: true,
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        initialize_day_params(options)
      end

      # 上座率 = 来店人数÷总餐位数×100%
      # 开台率 = 餐桌使用次数÷总台位数×100%
      # 翻台率 =（餐桌使用次数-总台位数）÷总台位数×100%

      def filters
        [
          filter_date
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
            rate_label(guest_num, meal_num * seat_count),
            rate_label(order_times, meal_num * table_count),
            rockover_rate(order_times, meal_num * table_count)
          ]
        end
        content
      end

    end
  end
end
