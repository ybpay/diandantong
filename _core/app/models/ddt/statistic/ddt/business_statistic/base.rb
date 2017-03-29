# encoding:utf-8
module Ddt
  module BusinessStatistic
    class Base < Ddt::StatisticBase
      attr_accessor :branch, :branch_id, :start_time, :end_time, :sort, :current_ability
      hash_attrs({
          门店: :branch_id,
          开始时间: :start_time,
          结束时间: :end_time,
          排序: :sort
      })

      def initialize(options={})
        super
        @branch_id = options[:branch_id]
        if @branch_id.present?
          @branch_id = Integer(@branch_id)
          @branch = @accessible_branches.detect{|b| b.id == @branch_id}
        end
        @start_time, @end_time = options[:start_time], options[:end_time]
        @sort = options[:sort].try(:to_sym)
      end
    end
  end
end
