module Ddt
  module Bill
    module Branch
      class PaymentList < ::Ddt::Bill::Branch::Base
        def content
          text = []
          text << "<CM>第三方支付流水</CM>\n"
          text << "店铺: #{@branch.name}"
          text << "时间: #{@start_time}"
          text << "  至: #{@end_time}\n"
          text << "-"*bill_width('80')
          items.each do |payment|
            line = []
            line << "单号: #{order_numbers[payment.order_id] rescue nil}"
            line << "金额: #{payment.amount.round(2) rescue nil}"
            line << "支付方式: #{payment.payment_method.name}"
            line << "状态: #{payment.workflow_state_name}"
            line << "交易号: #{payment.out_trade_no}"
            line << "创建时间: #{payment.created_at.strftime('%F %T')}"
            if payment.deleted_at.present?
              line << "删除时间: #{payment.deleted_at.strftime('%F %T')}"
            else
              line << "删除时间: "
            end
            text << line.join("\n")
          end
          text << "-"*bill_width('80')
          text << "读取人员: #{@operator.name}"
          text << "读取时间: #{Time.now}"
          text.join("\n")
        end

        def items
          @items ||= @branch.payments.with_deleted.includes(:payment_method).references(:ddt_payment_methods)
                              .where(ddt_payments: { created_at: @start_time..@end_time}).order('ddt_payments.created_at desc')
        end

        def order_numbers
          @order_numbers ||= OrderService::Api::Order.query({ id_in: items.map(&:order_id) }, { select: [:id, :number], includes: []})[:content].inject({}) do |numbers, order|
            numbers[order[:id]] = order[:number]
            numbers
          end
        end
      end
    end
  end
end
