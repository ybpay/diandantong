#encoding: utf-8
module Ddt
  module TableStatistic
    class RockoverRateByMonth < RockoverRate
      attr_accessor :year, :month
      hash_attrs({
          年份: :year,
          月份: :month
       })

      def self.class_info
        {
          name: 'rockover_rate_by_month',
          paginate: false,
          permit_params: [:branch_id, :year, :month],
          default_params: this_month,
          label: '翻台率(月平均)',
          sortable: true
        }
      end

      def initialize(options={})
        super
        initialize_month_params(options)
      end

      # 月平均上座率=月来店人数÷（总餐位数×2餐×30日）×100%
      # 月平均开台率=月餐桌使用次数÷（总台位数×2餐×30日）×100%
      # 月平均翻台率 = (月餐桌使用次数-（总台位数×2餐×30日）)×100% / 总台位数×2餐×30日
      # 打个比方说：你有100个台面，一天来的桌数小于100桌，那么翻台率为0，如果一天来了200桌，那么翻台率为100%


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
          days_num = Time.days_in_month(month, year)
          content << [
            branch_name,
            table_count,
            seat_count,
            order_times,
            order_times,
            guest_num,
            rate_label(guest_num, (meal_num * days_num * seat_count)),
            rate_label(order_times, (meal_num * days_num * table_count)),
            rockover_rate(order_times, (meal_num * days_num * table_count))
          ]
        end
        content
      end

      def filters
        [
          filter_year,
          filter_month
        ]
      end

      def to_combi_result
        items = result
        h = {}
        items.each do |item|
          branch_tables = get_branch_tables(item[:branch_id])
          table_count = branch_tables.count
          seat_count = sum(branch_tables, :capacity)
          order_times = (item[:times] || 0)
          guest_num = (item[:guest_num] || 0)
          end_time = (@end_time.is_a?(Time) ? @end_time : Time.parse(@end_time))
          start_time = (@start_time.is_a?(Time) ? @start_time : Time.parse(@start_time))
          days_num = ((end_time - start_time) / 1.day).ceil
          detail = {
            seat_rate: rate_label(guest_num, meal_num * days_num * seat_count),
            rockover_rate: rockover_rate(order_times, meal_num * days_num * table_count)
          }
          h[item[:branch_id]] = detail
        end
        h
      end

    end
  end
end
