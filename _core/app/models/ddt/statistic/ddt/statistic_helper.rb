#encoding: utf-8
module Ddt
  module StatisticHelper
    extend ActiveSupport::Concern

    included do
      def self.now
        Time.now
      end
    end

    def inc_rate_label(now, before)
      "#{inc_rate(now, before)}%"
    end

    def inc_rate(now, before)
      return nil_or_zero?(now) ? 0 : 100 if nil_or_zero?(now, before)
      ((1.0 * (now-before)/before)*100).round(2)
    end

    def rate_label(part, all)
      "#{rate(part, all)}%"
    end

    def rate(part, all)
      return nil_or_zero?(part) ? 0 : 100 if nil_or_zero?(part, all)
      ((1.0 * part / all)*100).round(2)
    end

    def avg(all, count)
      return 0 if nil_or_zero?(all, count)
      (1.0 * all / count).round(2)
    end

    def branches
      branch.present? ? [branch] : shop.branches
    end

    def group(collection, column)
      return {} if collection.blank?
      key = column.to_sym
      is_hash = (collection[0].is_a? Hash)
      collection.inject({}) do |hash, item|
        k = is_hash ? item[key] : item.send(key)
        hash[k] ||= [];
        hash[k] << item;
        hash
      end
    end

    def count_join(collection, column)
      return '' if collection.blank?
      counts = count(collection, column)
      counts.map{|k, v| "#{k.blank? ? '未填写' : k}(#{v})"}.join(",")
    end

    def count(collection, column)
      key = column.to_sym
      collection.inject({}) do |hash, item|
        hash[item[key]] ||= 0;
        hash[item[key]] += 1;
        hash
      end
    end

    def sum(collection, column=nil)
      return 0 if collection.blank?
      if block_given?
        collection.map{|item| yield(item) || 0}.inject(&:+) || 0
      elsif column.nil?
        return 0
      else
        key = column.to_sym
        is_hash = (collection[0].is_a? Hash)
        collection.inject(0) do |sum, item|
          return sum if item.nil?
          n = is_hash ? item[key] : item.send(key)
          sum += n.nil? ? 0 : n
        end
      end
    end

    def year_collection
      y = now.year
      y.downto(y-4).to_a.map{|y| [y, y]}
    end

    def month_collection
      (1..12).map{|m| [m, m]}
    end

    def week_collection
      [
        ["本 周 #{week_range(0)}", 0],
        ["上 周 #{week_range(1)}", 1],
        ["二周前 #{week_range(2)}", 2],
        ["三周前 #{week_range(3)}", 3],
        ["四周前 #{week_range(4)}", 4],
        ["五周前 #{week_range(5)}", 5]
      ]
    end
    def week_range(n)
      "#{n.week.ago.beginning_of_week.strftime("%m-%d")} ~ #{n.week.ago.end_of_week.strftime("%m-%d")}"
    end

    def initialize_day_params(options)
      if !options[:explicit_assign_time_range]
        @date = (Date.parse(options[:date]) rescue Date.today)
        @start_time = @date.beginning_of_day
        @end_time = @date.end_of_day
      end
    end

    def initialize_week_params(options)
      if !options[:explicit_assign_time_range]
        @week = Integer(options[:week].blank? ? 0 : options[:week])
        @start_time = @week.week.ago.beginning_of_week
        @end_time = @week.week.ago.end_of_week
      end
    end

    def initialize_month_params(options)
      if !options[:explicit_assign_time_range]
        y = options[:year].blank? ? now.year : options[:year]
        m = options[:month].blank? ? now.month : options[:month]
        @year = Integer(y)
        @month= Integer(m)
        @start_time = Time.new(year, month, 1, 0, 0, 0)
        @end_time = start_time.end_of_month
      end
    end

    def initialize_year_params(options)
      if !options[:explicit_assign_time_range]
        if options[:year].blank?
          @year = now.year
        else
          @year = Integer(options[:year])
        end
        @start_time = Time.new(year,1,1, 0,0,0)
        @end_time = @start_time.end_of_year
      end
    end

    def get_branch_name(branch_id, blank_label: '未知门店', noexist_label: '未知门店')
      return blank_label if branch_id.blank?
      @branches ||= shop.branches.with_deleted.with_abstract
      b = @branches.detect{|branch| branch.id == branch_id}
      return blank_label if b.is_abstract?
      b.present? ? b.name : (noexist_label+branch_id.to_s)
    end

    def now
      self.class.now
    end

    def split_query_all(query)
      query[:page] = query[:page] || 1
      query[:per_page] = query[:per_page] || Rails.env.production? ? 200 : 10
      current = yield query
      while current.size == query[:per_page]
        query[:page] += 1
        current = yield query
      end
    end

    def split_query_by_time(start_time:, end_time:, identity_keys: nil, accumulate_keys: nil, with_nil_record: false, concat: false, &block)
      date_start = (start_time.is_a? String) ? DateTime.parse(start_time) : start_time
      date_end = (end_time.is_a? String) ? DateTime.parse(end_time) : end_time
      date_count = date_end - date_start
      if @cache_record.present?
        @async_statistics_start_at ||= Time.now
      end

      result_array = []
      sum_hash = {}
      identity_keys ||= []
      accumulate_keys ||= []
      all_keys = identity_keys + accumulate_keys
      current_date = date_start
      next_date = current_date + 1.days
      while (next_date < date_end)
        inner_sqlit_query(
            current_date: current_date, next_date: next_date, has_next: true,
            with_nil_record: with_nil_record, result_array: result_array, concat: concat,
            sum_hash: sum_hash, all_keys: all_keys, identity_keys: identity_keys, accumulate_keys: accumulate_keys,
            &block
        )
        current_date = next_date
        next_date = current_date + 1.days

        progress = 100 * (current_date - date_start) / date_count
        @on_split_query_progress.call(progress) if @on_split_query_progress.present?
        if @cache_record.present?
          @cache_record.progress = progress
          @cache_record.cost_time = Time.now - @async_statistics_start_at
          @cache_record.save
        end
      end

      inner_sqlit_query(
          current_date: current_date, next_date: next_date, has_next: false,
          with_nil_record: with_nil_record, result_array: result_array, concat: concat,
          sum_hash: sum_hash, all_keys: all_keys, identity_keys: identity_keys, accumulate_keys: accumulate_keys,
          &block
      )

      concat ? result_array : sum_hash.values
    end

    private

      def inner_sqlit_query(
          current_date:,
          next_date:,
          has_next:,
          with_nil_record:,
          result_array:,
          concat:,
          sum_hash:,
          all_keys:,
          identity_keys:,
          accumulate_keys:
      )
        results = yield(current_date, next_date, has_next)
        if with_nil_record or !results.nil?
          if concat
            result_array.concat(results)
          else
            results.each do |result|
              hash_key = identity_keys.map {|key| result[key].to_s}.join('_')
              sum = sum_hash[hash_key]
              if sum.present?
                accumulate_keys.each { |key| sum[key] += result[key] || 0 }
              else
                sum = result.select{|k,v| all_keys.include?(k)}                 # 筛选字段
                accumulate_keys.each { |key| sum[key] = 0 if sum[key].blank? }  # 初始化统计字段
                sum_hash[hash_key] = sum
              end
            end
          end
        end
      end


      def nil_or_zero?(*nums)
        nums.each do |num|
          return true if num.nil? || num == 0
        end
        return false
      end



  end

end
