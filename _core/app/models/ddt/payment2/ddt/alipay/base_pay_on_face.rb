#encoding: utf-8
module Ddt
  module Alipay
    # alipay.trade.pay 当面付
    class BasePayOnFace < Ddt::Alipay::BaseOpenAlipay

      # 退款金额
      attr_accessor :refund_amount
      # 参与优惠计算的金额
      attr_accessor :discountable_amount
      # 订单描述
      attr_accessor :body

      # 商品列表
      # attr_accessor :goods_detail
      # # 操作员 (Account)
      # attr_accessor :operator_id
      # # 门店ID (Branch)
      # attr_accessor :store_id
      # 机具ID (WebposId)
      # attr_accessor :terminal_id

      # 系统商 ID
      attr_accessor :sys_service_provider_id

      def initialize(payment, request, options = {})
        super(payment, request, options)
        self.refund_amount = options[:refund_amount]
      end


      def refund
        service_params = partial_common_params.merge(
          {
               method: 'alipay.trade.refund',
               version: '1.0',
               biz_content: {
                   out_trade_no: self.out_trade_no,
                   refund_amount: self.refund_amount || self.payment.amount,
                   out_request_no: "TK#{self.out_trade_no}#{Time.now.strftime('%Y%m%d%H%M%S%s')}",
                   operator_id: self.order.try(:settle_account_id),
                   store_id: self.payment.branch_id,
                   terminal_id: self.order.try(:terminal_id),
               }.to_json
           })
        rsa_sign(service_params)

        result = {}
        send_request(service_params) do |resp_data|
          resp_data0 = resp_data.to_options[:alipay_trade_refund_response].to_options
          retry_flag = resp_data0[:code]
          if retry_flag == '10000'
            result.merge!({
                              success: true,
                              message: resp_data0[:msg],
                              data: resp_data0
                          })
          else
            result.merge!({
                              success: false,
                              message: resp_data0[:msg],
                              data: resp_data0
                          })
          end
          return result
        end
      end

      protected

      def partial_biz_content
        # TODO: 当组合支付时,无法区分支付宝支付的部分可折扣金额是多少
        discountable_amount = self.order.try(:adjustment_total).try(:abs)
        part = {
            out_trade_no: self.out_trade_no,
            total_amount: self.payment.amount,
            # undiscountable_amount: self.payment.amount,
            # discountable_amount: self.discountable_amount || self.payment.amount,
            discountable_amount: self.payment.amount,
            subject: self.subject,
            body: self.body,
            operator_id: self.order.try(:settle_account_id),
            store_id: self.payment.branch_id,
            terminal_id: self.order.try(:terminal_id),
            timeout_express: self.timeout_express
        }
        if self.order.present?
          part[:goods_detail] = self.payment.order.line_items.map do |line_item|
            {
                goods_id: "#{line_item.itemable_type.demodulize.underscore}\##{line_item.itemable_id}",
                # alipay_goods_id:
                goods_name: line_item.name,
                quantity: line_item.active_quantity,
                price: line_item.price,
                # goods_category:
                # body
            }
          end
        end
        part.compact
      end

    end
  end
end

