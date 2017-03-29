module Ddt
  module Schedule
    class CheckShiftWorker < Ddt::Schedule::Base
      def perform
        interval = 24.hours.ago..Time.now
        errors = Schedule::CheckShiftWorker.find_errors(closed_at: interval)
        body = []
        body << "检查时间 #{interval.begin.strftime('%F %T')} ~ #{interval.end.strftime('%F %T')}"
        body << "总数 #{errors.count}"
        errors.each do |error|
          line = []
          line << error[:shift].branch_id
          line << error[:shift].branch.try(:name)
          line << error[:shift].id
          line << error[:shift].total_amount
          line << error[:shift].discount_amount
          line << error[:total_amount]
          line << error[:discount_amount]
          body << line.join("   ")
        end
        BaseMailer.notify(Rails.application.config.dev_mail_group, "[班次数据检查]", body.join("\n"))
      end

      def self.find_errors(params={})
        errors = []
        Shift.closed.where(params).find_each do |shift|
          pay_item_amounts = OrderService::Api::Statistic.pay_item_amount(
            query: {
              branch_id_eq: shift.branch.id,
              paid_at_gteq: shift.created_at,
              paid_at_lteq: shift.closed_at,
              order_type_in: ["Ddt::EatInHallOrder", "Ddt::FastfoodOrder", "Ddt::DeliveryOrder", "Ddt::ReservationOrder", "Ddt::PaymentOrder", "Ddt::GrouponOrder"],
            }
          )
          total_amount = pay_item_amounts.map{|item| item[:amount]}.sum.to_f.round(2)
          discount_amount = OrderService::Api::Statistic.adjustment_amount(query: {
            branch_id_eq: shift.branch_id,
            created_at_gteq: shift.created_at,
            created_at_lteq: shift.closed_at,
            reason_in: OrderService::Adjustment.discount_reasons
          })
          if shift.total_amount != total_amount || shift.discount_amount != discount_amount
            errors.push({
              shift: shift,
              total_amount: total_amount,
              discount_amount: discount_amount
            })
          end
        end
        errors
      end

      def self.find_by_branch(branch_id)
        errors = Schedule::CheckShiftWorker.find_errors(branch_id: branch_id)
        branch = Branch.find(branch_id)
        puts "检查门店 #{branch.name}"
        puts "总数 #{errors.count}"
        errors.each do |error|
          line = []
          line << error[:shift].id
          line << error[:shift].created_at.strftime("%F %T")
          line << error[:shift].closed_at.strftime("%F %T")
          line << error[:shift].total_amount
          line << error[:shift].discount_amount
          line << error[:total_amount]
          line << error[:discount_amount]
          puts line.join("    ")
        end
        errors.count
      end
    end
  end
end
