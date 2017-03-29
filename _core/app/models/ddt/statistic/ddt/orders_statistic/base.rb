#encoding: utf-8
module Ddt
  module OrdersStatistic
    class Base < ::Ddt::StatisticBase
      attr_accessor :branch_id, :start_time, :end_time
      hash_attrs({
          门店: :branch_id,
          开始时间: :start_time,
          结束时间: :end_time
      })

      def initialize(options={})
        super
        @branch_id = options[:branch_id]
        @start_time = options[:start_time]
        @end_time = options[:end_time]
      end
    end
  end
end
