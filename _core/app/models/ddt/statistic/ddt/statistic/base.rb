module Ddt
  class Statistic
    class Base
      attr_accessor :sale_employee, :shop, :branch, :start_date, :end_date, :time_filter, :interval, :until_now, :group_by, :q
      # time_filter [:today, :yesterday, :this_week, :last_week, :this_month, :last_month, :this_year, :last_year]
      # interval [:day, :month, :year, :all]
      def initialize(options={})
        @sale_employee = Ddt::SaleEmployee.find(options[:sale_employee_id]) if options[:sale_employee_id]
        @shop = Ddt::Shop.find(options[:shop_id]) if options[:shop_id]
        @branch = Ddt::Branch.find(options[:branch_id]) if options[:branch_id]
        @start_date, @end_date = options[:start_date], options[:end_date]
        @time_filter = options[:time_filter]
        @group_by = options[:group_by]
        @q = options[:q] || {}
        @start_date, @end_date = get_time_filter_date if @time_filter.present?
        if [:this_year, :last_year].include? @time_filter
          @interval = options[:interval] || :month
        else
          @interval = options[:interval] || :day
        end
        @until_now = options[:until_now]
      end

      def query
        raise "Not Implement"
      end

      def query_with_cache
        @qeury_cache ||= query_without_cache
      end

      def group_by_time_interval(time_column: "paid_at", sql_format: false, table_name: nil)
        if [:day, :month, :year].include?(interval.to_sym)
          case interval.to_sym
          when :day
            hash_all = Hash[date_array.map { |v| [v.strftime('%m-%d'), 0] }]
            group_column = "#{time_column}_day"
          when :month
            hash_all = Hash[date_array.map(&:beginning_of_month).uniq.map{|m| [m.strftime('%Y-%m'), 0]}]
            group_column = "#{time_column}_month"
          when :year
            hash_all = Hash[date_array.map(&:beginning_of_year).uniq.map{|m| [m.strftime('%Y'), 0]}]
            group_column = "#{time_column}_year"
          end
          group_column = self.class.group_by_time_type_to_sql(group_column, table_name: table_name) if sql_format
          result = yield([group_by, group_column].compact)
          if group_by.present?
            result.map{|k, v| [k, hash_all.symbolize_keys.merge(v)]}.to_h
          else
            hash_all.symbolize_keys.merge(result.symbolize_keys)
          end
        elsif interval.to_sym == :total
          yield
        end
      end

      def self.group_by_time_type_to_sql(time_type, table_name: :ddt_orders)
        time_column = time_type.to_s.split("_")[0..-2].join("_")
        type = time_type.to_s.split("_")[-1]
        case type.to_sym
        when :day
          "TO_CHAR(#{table_name}.#{time_column}, 'MM-DD')"
        when :month
          "TO_CHAR(#{table_name}.#{time_column}, 'YYYY-MM')"
        when :year
          "TO_CHAR(#{table_name}.#{time_column}, 'YYYY')"
        end
      end

      def date_array
        start_date.to_date..end_date.to_date
      end

      def query
        raise
      end

      def self.time_filter_collection
        {this_week: '本周', last_week: '上周', this_month: '本月', last_month: '上月', this_year: '本年', last_year: '去年'}
      end

      def tick_interval
        time_filter.present? ? time_filter_tick_interval : (date_array.count / 10)
      end

      def labels
        @label ||=
          if time_filter.present?
            time_filter_labels
          else
            (start_date..end_date).map do |date|
              "#{date.strftime('%m-%d')}"
            end
          end
      end

      [:get_time_filter_date, :time_filter_tick_interval, :time_filter_labels].each do |name|
        define_method name do
          self.class.send(name, time_filter, until_now)
        end
      end

      def self.get_time_filter_date(time_filter, until_now=false)
        start_date, end_date =
          case time_filter.to_sym
          when :today
            [Time.now.beginning_of_day, Time.now.end_of_day]
          when :yesterday
            [1.day.ago.beginning_of_day, 1.day.ago.end_of_day]
          when :this_week
            [Time.now.beginning_of_week, Time.now.end_of_week]
          when :last_week
            [1.week.ago.beginning_of_week, 1.week.ago.end_of_week]
          when :this_month
            [Time.now.beginning_of_month, Time.now.end_of_month]
          when :last_month
            [1.month.ago.beginning_of_month, 1.month.ago.end_of_month]
          when :this_year
            [Time.now.beginning_of_year, Time.now.end_of_year]
          when :last_year
            [1.year.ago.beginning_of_year, 1.year.ago.end_of_year]
          end
        end_date = [end_date, Date.today].min if until_now
        [start_date, end_date]
      end

      def self.time_filter_tick_interval(time_filter, until_now=false)
        case time_filter
        when :this_week, :last_week
          2
        when :this_month, :last_month
          5
        when :this_year, :last_year
          3
        end
      end

      def self.time_filter_labels(time_filter, until_now=false)
        case time_filter
        when :this_week
          week_labels(Date.today, until_now)
        when :last_week
          week_labels(1.week.ago.to_date, until_now)
        when :this_month
          month_labels(Date.today, until_now)
        when :last_month
          month_labels(1.month.ago.to_date, until_now)
        when :this_year
          year_labels(Date.today, until_now)
        when :last_year
          year_labels(1.year.ago.to_date, until_now)
        end
      end

      def self.week_labels(date, until_now=false)
        start_date = date.beginning_of_week
        end_date = date.end_of_week
        end_date = [end_date, Date.today].min if until_now
        (start_date..end_date).map do |date|
          "#{date.strftime('%m-%d')} #{%w[周日 周一 周二 周三 周四 周五 周六][date.wday]}"
        end
      end

      def self.month_labels(date, until_now=false)
        start_date = date.beginning_of_month
        end_date = date.end_of_month
        end_date = [end_date, Date.today].min if until_now
        (start_date..end_date).map do |date|
          "#{date.strftime('%m-%d')}"
        end
      end

      def self.year_labels(date, until_now=false)
        start_date = date.beginning_of_year
        end_date = date.end_of_year
        end_date = [end_date, Date.today].min if until_now
        (start_date..end_date).map do |date|
          "#{date.strftime('%Y-%m')}"
        end.uniq
      end
    end
  end
end
