#encoding: utf-8
module Ddt
  module BusinessStatistic
    class Sales < ::Ddt::BusinessStatistic::Base
      attr_accessor :search_by
      hash_attrs({
          搜索方式: :search_by,
          补全空白: :fill_empty
       })

      def initialize(options)
        super
        @search_by = options[:search_by] || 'shift_opened_at'
        @fill_empty = !options[:ignore_empty_data]
      end

      def search_by_collection
        [
          ['按开班时间', 'shift_opened_at'],
          ['按结算时间', 'order_paid_at']
        ]
      end

      def filter_search_by
        {name: 'search_by', type: 'collection', collection: search_by_collection, prompt: '统计依据'}
      end

      def shift_item_type
        :base
      end

      def by_shift_opened_at?
        'shift_opened_at' == @search_by
      end

      def append_select_column
        nil
      end

      def append_group_column
        nil
      end

      def shift_item_summarys
        if by_shift_opened_at?
          shift_item_summarys_by_sql
        else
          shift_item_summarys_by_fake
        end
      end

      cache_result

      def labels
        []
      end

      def keys
        []
      end

      def filter_blk
        nil
      end

      def group_by_time_type_to_sql_simple(time_type, table_name: :ddt_shifts)
        time_column = time_type.to_s.split("_")[0..-2].join("_")
        type = time_type.to_s.split("_")[-1]
        case type.to_sym
        when :hour
          "TO_CHAR(#{table_name}.#{time_column}, 'HH24')"
        when :day
          "TO_CHAR(#{table_name}.#{time_column}, 'DD')"
        when :week
          "EXTRACT(DOW FROM #{table_name}.#{time_column})::text"
        when :month
          "TO_CHAR(#{table_name}.#{time_column}, 'DD')"
        when :year
          "TO_CHAR(#{table_name}.#{time_column}, 'MM')"
        end
      end

      def select_by_time_type_to_sql_simple(time_type, table_name: :ddt_shifts)
        time_column = time_type.to_s.split("_")[0..-2].join("_")
        type = time_type.to_s.split("_")[-1]
        case type.to_sym
        when :hour
          "TO_CHAR(#{table_name}.#{time_column}, 'HH24') as time"
        when :day
          "TO_CHAR(#{table_name}.#{time_column}, 'DD') as time"
        when :week
          "EXTRACT(DOW FROM #{table_name}.#{time_column})::text as time"
        when :month
          "TO_CHAR(#{table_name}.#{time_column}, 'DD') as time"
        when :year
          "TO_CHAR(#{table_name}.#{time_column}, 'MM') as time"
        end
      end

      def wallet_log_time_format
        group_by_time_type_to_sql_simple(group_by_column.to_s.gsub('paid_at', 'created_at'), table_name: :ddt_wallet_logs)
      end

      def paid_at_time_format(paid_at)
        paid_at = Time.parse(paid_at) if !paid_at.is_a? Time
        case group_by_column
        when :paid_at_day
          paid_at.strftime('%d')
        when :paid_at_week
          paid_at.strftime('%w')
        when :paid_at_month
          paid_at.strftime('%d')
        when :paid_at_year
          paid_at.strftime('%m')
        end
      end

    end
  end
end
