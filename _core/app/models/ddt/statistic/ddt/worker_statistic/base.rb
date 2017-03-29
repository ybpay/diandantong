#encoding: utf-8
module Ddt
  module WorkerStatistic
    class Base < Ddt::StatisticBase
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
        @start_time = Time.now.beginning_of_month if @start_time.blank?
        @end_time = Time.now.end_of_month if @end_time.blank?
      end

      def filters
        [
          {name: 'branch_id', type: 'ddselect2', data: {useas: "local_select", "local-datas" => accessible_branches, single: true, placeholder: "选择门店"}},
          {name: 'start_time', type: 'datetime', placeholder: '开始时间'},
          {name: 'end_time', type:'datetime', placeholder: '结束时间'}
        ]
      end

    end
  end
end
