#encoding: utf-8
module Ddt
  module OrdersStatistic
    class ChangeLog < OrdersStatistic::Base
      attr_accessor :year, :month
      hash_attrs({
        年份: :year,
        月份: :month
     })

      def self.class_info
        {
          name: 'change_log',
          paginate: false,
          permit_params: [:branch_id, :year, :month],
          default_params: this_month,
          label: '退单与反结帐',
          sortable: true,
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        initialize_month_params(options)
      end

      def labels
        keys.map do |k|
          wday = Date.new(year, month, k.to_i).wday
          wlabel = Ddt::TimeUtil.week_label(wday)
          "#{'%02d' % month}-#{k}(#{wlabel})"
        end
      end

      def keys
        (start_time.day..end_time.day).map do |day|
          "%02d" % day
        end
      end

      def types
        ["Ddt::OrderChangeLog::OrderCancel", "Ddt::OrderChangeLog::AntiSettlement"]
      end


      def result
        return [] if branch_id.blank?
        @items ||= Ddt::OrderService::Api::Statistic.order_change_count(
          query: {
            shop_id_eq: shop.id,
            type_in: types,
            branch_id_eq: branch_id,
            created_at_gteq: start_time,
            created_at_lteq: end_time
          },
        group_by: [:created_at_month, :type])
      end
      cache_result

      def title
        ['日期', '退单次数', '反结帐次数', '退菜数量', '退菜金额']
      end

      def body
        items = result
        content = []
        keys.each_with_index do |key, index|
          label = labels[index]
          cancel_order_times    = items.detect{|item| item.time == key && item.type == 'Ddt::OrderChangeLog::OrderCancel'}.times rescue 0
          anti_settlement_times = items.detect{|item| item.time == key && item.type == 'Ddt::OrderChangeLog::AntiSettlement'}.times rescue 0
          delete_itemable_count = subtract_count[key][:count] rescue 0
          delete_itemable_amount = subtract_count[key][:amount] rescue 0
          content << [
            label,
            cancel_order_times,
            anti_settlement_times,
            delete_itemable_count,
            delete_itemable_amount
          ]
        end
        content
      end

      def filters
        [
          filter_branch(support_all: false),
          filter_year,
          filter_month
        ]
      end

      def subtract_count
        # result:
        # {
        #   '01': {count: 1, amount: 20}
        # }
        return @subtract_result if @subtract_result.present?
        @subtract_result = {}
        @subtract_items ||= Ddt::OrderService::Api::Statistic.subtract_item_list(
          {query: {
            shop_id_eq: shop.id,
            branch_id_eq: branch_id,
            created_at_gteq: start_time,
            created_at_lteq: end_time
          }})
        filter_blk = Proc.new{|subtract_item| Time.parse(subtract_item[:created_at]).strftime("%d")}
        @subtract_items.group_by(&filter_blk).each do |key, items|
          @subtract_result[key] = {}
          @subtract_result[key][:count] = sum(items, :quantity)
          @subtract_result[key][:amount]= items.map{|item| item[:quantity] * item[:price]}.sum
        end
        @subtract_result
      end

    end
  end
end
