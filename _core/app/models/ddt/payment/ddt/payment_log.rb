#encoding: utf-8
module Ddt
  class PaymentLog < Ddt::DdtEx
    include BelongsToShop
    include BelongsToBranch
    skip_validate_branch
    include ActsAsType

    def payment
      Ddt::Payment.with_deleted.find_by(id: payment_id)
    end

    belongs_to :order
    acts_as_type_hash :event, {
      checkout: '初始化请求',
      alipay_service_params: '支付宝服务参数',
      alipay_confirm_params: '支付宝验证参数',
      generate: '生成支付请求',
      process_error: '请求处理错误',
      notify: '收到支付通知',
      notify_success: '通知处理成功',
      notify_error: '通知处理出错',
      verify_success: '校验支付成功',
      close_error: '关闭交易出错',
      close_success: '关闭交易成功',
      refund_success: '退款成功',
      refund_error: '退款失败',

      wechat_unifiedorder: '调用微信统一支付接口',
      wechat_micropay: '调用微信移动支付接口'
    }

    validates_presence_of :payment
    after_save :log_to_file

    before_validation do
      if payment.present?
        self.shop_id = payment.shop_id
        self.branch_id = payment.branch_id
        self.order_id = payment.order_id
        self.payment_id = payment.id
        self.amount = payment.amount
        self.out_trade_no = payment.out_trade_no
        self.payment_state = payment.workflow_state
        self.payment_method_name = payment.payment_method.try(:name)
        if payment.order.present?
          self.order_number = payment.order.number
          self.multi_pay_item = payment.order.multi_pay_item?
        end
        true
      else
        false
      end
    end

    def self.log(payment, params)
      self.delay_for(1.minutes).log0(payment.id, params)
    end

    def self.log0(payment_id, params)
      begin
        payment = Ddt::Payment.find(payment_id)
        if payment.present?
          payment.payment_logs.create!(params)
        else
          raise "log payment##{payment_id} failed: no such record. params=#{params}"
        end
      rescue => e
        Rails.logger.payments.error(e)
        ExceptionNotifier.notify_exception(e)
      end
    end

    private
    def log_to_file
      Rails.logger.payment_logs.info(self.to_json)
    end

  end
end
