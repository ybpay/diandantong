# encoding:utf-8
module Ddt
  module BusinessStatistic
    class FlowOfCustomer < ::Ddt::BusinessStatistic::Base
      attr_accessor :year, :last_year, :include_last_year
      hash_attrs({
          包含去年: :include_last_year,
          年份: :year
      })

      def self.class_info
        {
          name: 'flow_of_customer',
          paginate: false,
          permit_params: [:branch_id, :year],
          label: '客流及人均'
        }
      end

      def initialize(options={})
        super
        @include_last_year = options[:include_last_year]
        initialize_year_params(options)
        if @include_last_year.nil?
          last_year_options = options.dup
          @last_year = self.class.new(last_year_options.merge!(year: @year-1, include_last_year: false, is_async: false))
        end
      end

      def result
        if one_branch?
          @items = Ddt::Shift.closed.where(shop_id: shop.id, branch_id: branch_id, created_at: start_time..end_time)
        elsif branch_id.present?
          @items = Ddt::Shift.closed.where(shop_id: shop.id, created_at: start_time..end_time)
        else
          return []
        end
        calculate(@items)
      end
      cache_result

      def labels
        (1..12).map{|i| "#{i}月"}
      end

      def keys
        (1..12).map{|i| "%02d"%i}
      end

      def calculate(items)
        shift_count = items.size
        summary = items.group_by{|item| item.created_at.strftime("%m")}
        result = {}
        summary.each_pair do |month, shifts|
          result[month] = {
            total_customer_count: sum(shifts, :total_customter_count),
            per_capita_consumption: (1.0 * sum(shifts, :per_capita_consumption)/shift_count).round(4)*100,
            total_open_table_count: sum(shifts, :total_eat_in_hall_order_count),
            per_eat_in_hall_order_consumption: (1.0 * sum(shifts, :per_eat_in_hall_order_consumption)/shift_count).round(4)*100
          }
        end
        fill_empty(result)
      end

      def fill_empty(summarys)
        keys.each do |key|
          if summarys[key].blank?
            summarys[key] = {
              total_customter_count: 0,
              per_capita_consumption: 0,
              total_open_table_count: 0,
              per_eat_in_hall_order_consumption: 0
            }
          end
        end
        summarys
      end

      def year_collection
        y = Time.now.year
        y.downto(y-4).to_a.map{|y| [y, y]}
      end

      def table_nums
        return @table_nums if @table_nums.present?
        if branch_id != 0
          @table_nums = Ddt::Table.with_deleted.where(shop_id: shop.id, branch_id: branch_id).count
        else
          @table_nums = Ddt::Table.with_deleted.where(shop_id: shop.id).count
        end
      end


      def filters
        [
          filter_branch,
          filter_year
        ]
      end

      def title
        %w[月份 客流量(本) 客流量(上年同期) 客流量(增) 开台量(本) 开台量(上年同期) 开台量(增) 人均消费(本) 人均消费(上年同期) 人均消费(增) 单均消费(本) 单均消费(上年同期) 单均消费(增)]
      end

      def custom_thead?
        true
      end

      def custom_thead
        thead = []
        tr1 = [{name: '月份', th_attrs: {rowspan: 2}}]
        %W[客流量 开台量 人均消费 单均消费].each do |name|
          tr1 << {name: name, th_attrs: {colspan: 3}}
        end
        tr2 = []
        4.times do |i|
          tr2 << {name: '本月'}
          tr2 << {name: '上年同期'}
          tr2 << {name: '增长率'}
        end
        thead << tr1
        thead << tr2
        thead
      end

      def body
        summarys = result
        last_year_summarys = last_year.result
        content = []
        return [] if summarys.blank?
        keys.each_with_index do |key, index|
          summary = summarys[key]
          last_year_summary = last_year_summarys[key]
          content << [
            labels[index],
            summary[:total_customter_count],
            last_year_summary[:total_customter_count],
            inc_rate_label(summary[:total_customter_count], last_year_summary[:total_customter_count]),
            summary[:total_open_table_count],
            last_year_summary[:total_open_table_count],
            inc_rate_label(summary[:total_open_table_count], last_year_summary[:total_open_table_count]),
            summary[:per_capita_consumption],
            last_year_summary[:per_capita_consumption],
            inc_rate_label(summary[:per_capita_consumption], last_year_summary[:per_capita_consumption]),
            summary[:per_eat_in_hall_order_consumption],
            last_year_summary[:per_eat_in_hall_order_consumption],
            inc_rate_label(summary[:per_eat_in_hall_order_consumption], last_year_summary[:per_eat_in_hall_order_consumption])
          ]
        end
        content
      end



    end
  end
end
