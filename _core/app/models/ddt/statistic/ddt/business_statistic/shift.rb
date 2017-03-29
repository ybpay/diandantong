# encoding:utf-8
module Ddt
  module BusinessStatistic
    class Shift < ::Ddt::BusinessStatistic::Base

      def self.class_info
        {
          name: 'shift',
          paginate: false,
          permit_params: [:branch_id, :start_time, :end_time],
          label: '营收统计',
          render_view: true
        }
      end

      def result
        @result ||= shop.shifts.closed.where(branch_id: branch_id, created_at: start_time..end_time)
      end

      cache_result do |result|
        @result ||= result
      end

      def to_csv(file = StringIO.new)
        csv = CSV.new(file)
        shifts = self.result
        keys = %W(商铺 当班人 开班时间 交班时间 合计金额 实收金额 会员卡充值金额 会员卡兑换金额 当班前未完成订单(未确认) 当班后未完成订单(未确认) 当班前未完成订单(已确认) 当班后未完成订单(已确认) 当班时间内完成的订单)
        csv << keys
        shifts.each do |shift|
          csv_line = []
          csv_line << shift.branch.name
          csv_line << shift.account.try(:name)
          csv_line << shift.created_at.strftime("%F %T")
          csv_line << shift.closed_at.strftime("%F %T")
          csv_line << shift.total_amount
          csv_line << shift.total_actual_amount
          csv_line << shift.recharge_amount
          csv_line << shift.exchange_amount
          csv_line << shift.pending_orders_before
          csv_line << shift.pending_orders_after
          csv_line << shift.confirmed_orders_before
          csv_line << shift.confirmed_orders_after
          csv_line << shift.completed_orders_after - shift.completed_orders_before
          csv << csv_line
        end
        csv_line = []
        csv_line << "总计"
        csv_line << ""
        csv_line << ""
        csv_line << ""
        csv_line << shifts.sum(:total_amount)
        csv_line << shifts.sum(:total_actual_amount)
        csv_line << shifts.sum(:recharge_amount)
        csv_line << shifts.sum(:exchange_amount)
        csv_line << ''
        csv_line << ''
        csv_line << ''
        csv_line << ''
        csv_line << shifts.sum('completed_orders_after - completed_orders_before')
        csv << csv_line
        file
      end
    end
  end
end
