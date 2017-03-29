#encoding: utf-8
module Ddt
  module CouponStatistic
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
          @start_time = Time.now.beginning_of_month
          @end_time = Time.now.end_of_month
        end
      end

      cache_result

    end
  end
end
