#encoding: utf-8
module Ddt
  module FinanceStatistic
    class Base < ::Ddt::StatisticBase
      attr_accessor :start_time, :end_time
      hash_attrs({
          开始时间: :start_time,
          结束时间: :end_time
      })
      def initialize(options={})
        super
        @start_time = options[:start_time]
        @end_time = options[:end_time]
        if @start_time.blank?
          @start_time = Time.now.beginning_of_day
          @end_time = Time.now.end_of_day
        end
      end
    end
  end
end
