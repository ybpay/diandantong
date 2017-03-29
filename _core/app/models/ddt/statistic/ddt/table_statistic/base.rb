#encoding: utf-8
module Ddt
  module TableStatistic
    class Base < ::Ddt::StatisticBase
      attr_accessor :start_time, :end_time, :branch_id
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
        @start_time = Time.now.beginning_of_month if @start_time.blank?
        @end_time = Time.now.end_of_month if @end_time.blank?
      end
    end
  end
end
