# encoding:utf-8
#
# 支付接口，Model 提供支付接口支撑 API
#

module Ddt

  # TODO: 等待用户输入密码时, 若点重新结算, 然后用户完成支付, 会导致支付没被确认
  # 故重新结算在线支付项目需要在 15 秒后进行,以等待客人密码输入完成

  class Payment < Base
    include Ddt::SoftDeletable
    include BelongsToBranch
    include AASM
    belongs_to_order
    has_one_pay_item
    belongs_to :payment_method, class_name: '::Ddt::PaymentMethod'
    has_many :payment_logs, class_name: '::Ddt::PaymentLog'
    preference :generate_log, :text
    preference :notify_log, :text
    preference :notify_result, :text
    preference :sub_method, :text
    preference :check_count, :integer # 检查是否完成次数
    preference :last_check_at, :integer
    set_from :order
    after_create :check_amount
    before_destroy :rollback_remote_payment
    # attr_accessible :partner_id         # 收款帐户（alipay: pid, wechatpay: partner_id)
    # attr_accessible :out_trade_no       # 交易号

    # checkout: Checkout has not been completed
    # processing: The payment is being processed (temporary – intended to prevent double submission)
    # pending: The payment has been processed but is not yet complete (ex. authorized but not captured)
    # failed: The payment was rejected (ex. credit card was declined)
    # void: The payment should not be counted against the order
    # completed: The payment is completed. Only payments in this state count against the order total

    acts_as_type :workflow_state,
                 [:checkout, :processing, :pending, :completed, :void, :failed, :closed, :refunded],
                 %w(待处理 处理中 待支付 已完成 已取消 已失败 已关闭 已退款)
    scope :completed, ->{ where(workflow_state: :completed )}
    scope :imcompleted, ->{ where.not(workflow_state: :completed)}
    scope :checkout, ->{ where(workflow_state: :checkout)}
    scope :of_payable, -> { where(workflow_state: [:checkout, :processing, :pending]).order(created_at: :desc)}
    scope :refunded, -> { where(workflow_state: :refunded)}
    # scope :of_branch_present, -> { where(::Ddt::Branch.where('ddt_branches.id = ddt_payments.branch_id').limit(1).arel.exists)}

    aasm column: :workflow_state, initial: :checkout, create_scopes: false do
      state :checkout, :processing, :pending, :completed, :void, :failed, :closed, :refunded

      event :start_process do
        transitions from: :checkout, to: :processing
      end
      event :do_close do
        transitions from: :checkout, to: :closed
        transitions from: :processing, to: :closed
        transitions from: :pending, to: :closed
      end
      event :do_process do
        transitions from: :processing, to: :pending
      end
      event :fail do
        transitions from: :processing, to: :failed
        transitions from: :pending, to: :failed
      end
      event :complete do
        transitions from: :pending, to: :completed
      end
      event :refund do
        transitions from: :completed, to: :refunded
      end

      after_transition to: :pending do |payment, transition|
        payment.reload
        if payment.payment_method.respond_to?(:after_pending)
          result = payment.payment_method.after_pending(*transition.args)
          payment.query if result
        end
      end
    end

    def self.notify_url(payment, request)
      "http://#{request.host}:#{request.port}/oapi/v1/payments/#{payment.id}/notify"
    end

    def state
      self.workflow_state
    end

    #
    # 处理支付，生成支付 URL 并返回
    # 订单状态：
    # checkout: 触发支付发起流程
    # processing: 继续未完/重试支付流程，这可能涉及到参数的改变
    # pending/completed/failed/void: 返回支付起起流程得到的结果
    #
    # options 支持的参数列表
    #   subject 商品名
    #   callback_url 支付完成的回调 URL
    # 返回结果
    # {
    #     method: alipay/wechatpay ... 支付接口流程
    #     version: 支付接口版本
    #     out_trade_no: 订单标识
    #     partner_id: 门店标识
    #     data_type: url/NATIVE/JSAPI
    #     data: ......
    #     qr_code_url: 支付二维码(目前支持 wechatpay 3.36+, alipay)
    # }
    #
    # 对于支付宝，此函数返回的 data 是可用于跳转的 URL
    # 对于微信支付，因目前仅支持 JS API，返回的是 JS 所用的参数
    # legacy:
    #   data_type: JSAPI
    #   data: 用于 WeixinJSBridge.invoke('getBrandWCPayRequest', data, callback)
    # v3.3.6:
    #   data_type: NATIVE/JSAPI
    #   data: JSAPI 情况下，与 legacy 相同，NATIVE 下，为可用于微信客户端的支付 URL，可转为二维码
    # 当使用 v3.3.6 的微信支付接口时，需要通过 options 或 request.cookies[cookie_open_id_index]
    # 传递用户相对于支付公众号的 openid
    # 否则接口抛出一个的异常，使用者可用之向微信服务器获取 openid
    # {
    #   method: wechatpay
    #   version: 3.3.6
    #   data_type: oauth2_url
    #   data: 用于跳转的 URL
    # }
    # 此授权 URL 获取 code ，再利用 code 获得 openid，再回传到本接口
    #
    def process(request, options = {})
      result = nil
      begin
        case self.workflow_state
          when 'checkout'
            Rails.logger.payments.info "[checkout] #{{payment_id: self.id, params: request.params, options: options}}"
            PaymentLog.log(self, event: 'checkout', extra: {params: request.params, options: options}.to_json)

            self.with_lock(true) do
              self.start_process!
            end

            self.with_lock(true) do
              result = self.do_process!(request, options)
            end

            Rails.logger.payments.info "[generate] #{{payment_id: self.id, result: result}}"
            PaymentLog.log(self, event: 'generate', extra: result.to_json)

            Payment.delay_for(5.seconds).check_payment_completed(self.id)

          when 'processing'
            # 目前进入这种状态只有微信支付 v3.3.6
            # 当上一次使用本接口，不传入 openid，将会使其中方法抛出异常
            self.with_lock(true) do
              result = self.do_process!(request, options)
            end
            Rails.logger.payments.info "[generate] #{{payment_id: self.id, result: result}}"
            PaymentLog.log(self, event: 'generate', extra: result.to_json)
          else
            result = JSON.parse(self.preferred_generate_log)
        end
      rescue ::Ddt::NoWechatpayOpenIdException => e
        result = JSON.parse(e.message)
      rescue ::Ddt::PaymentException => e
        log(:exception, exception: e.message)
        PaymentLog.log(self, event: 'process_error', extra: e.log_json_entry.to_json)
        result = {
            method: 'exception',
            data: e.message
        }
      rescue => exception
        log(:exception, exception: exception)
        puts exception.message
        puts exception.backtrace
        PaymentLog.log(self, event: 'process_error', extra: {exception_message: exception.message}.to_json)
        result = {
            method: 'exception',
            data: exception.message
        }
      end

      return result
    end

    #
    # 支付成功/失败通知
    # notify 返回一个 json 对象
    # {
    #   verify: true/false  # 校验成功或失败
    #   content_type        # 输出格式
    #   content:            # 指导最终输出内容
    # }
    #
    def notify(request)
      case self.workflow_state
        when 'pending'
          result = self.payment_method.notify(self, request)
          if result[:verify]
            self.on_verify_success(result, request)
          end
        when 'completed'
          result = JSON.parse(preferred_notify_result)
        else
          raise "unexcepted payment #{id} with invalid state #{self.workflow_state}"
      end
      result
    end

    # 如果检验成功，则修改支付状态，并通知 Order 做后续处理
    def on_verify_success(result = nil, request = nil)
      if result.nil?
        result = {
            :verify => true,
            :content_type => 'text/plain',
            :content => 'success'
        }
      end

      if request.nil?
        request = {
            params: {
                from: payment_method.type,
                sync: 'true'
            }
        }
      end
      self.complete!(request, result)
      PaymentLog.log(self, event: 'verify_success', extra: result.to_json)
    end

    #
    # !!! IMPORTANT !!!
    # 查询订单状态，如果订单支付成功则返回 TRUE
    # 目前仅供 微信支付/支付宝 的接口，百付宝暂不支持
    #
    def query
      # 查询订单是否支付完成，如果当前订单状态未支付完成，向微信服务器查询以同步支付状态。
      # 适用于被扫支付
      if self.order.is_paid?
        true
      else
        if self.payment_method.query(self)
          on_verify_success if self.is_pending?
          true
        else
          false
        end
      end
    end

    #
    # 关闭交易
    #
    # 关闭交易
    # {
    #   success: T/F 是否关闭成功
    #   message: 关闭交易返回的消息
    #   data: 详细信息
    # }
    #
    def close
      if closed?
        result = {
            success: false,
            message: '交易已关闭'
        }
      else
        begin
          Rails.logger.payments.info("[send_close] #{{payment_id:self.id}}")
          result = payment_method.close(self)

          Rails.logger.payments.info("[close_result] #{{payment_id:self.id, result: result}}")
          if result[:success]
            if self.may_do_close?
              do_close!(result)
              PaymentLog.log(self, event: :close_success, extra: result[:data].try(:to_json))
            end
          else
            PaymentLog.log(self, event: :close_error, extra: result[:data].try(:to_json))
          end

        rescue => e
          result = {
              success: false,
              message: e.message
          }
          PaymentLog.log(self, event: :close_error, extra: {exception_message: e.message}.to_json)
        end
      end

      result
    end

    CHECK_INTERVALS = [5.seconds, 5.seconds, 5.seconds, 5.seconds, 5.seconds, 5.seconds, 5.seconds, 5.seconds, 5.seconds]
    def self.check_payment_completed(payment_id)
      ::Ddt::Payment.transaction do
        payment = ::Ddt::Payment.where(id: payment_id).lock(true).first
        if payment.preferred_last_check_at.present?
          last_check_at = Time.at(payment.preferred_last_check_at)
          if last_check_at >= 4.seconds.ago
            return
          end
        end
        payment.update(preferred_last_check_at: Time.now.to_i)

        Rails.logger.payments.info("[check_payment_completed] before check payment##{payment.id} #{payment.preferred_check_count} times, payment state is #{payment.state}")

        payment.query
        if payment.preferred_check_count.present?
          payment.update(:preferred_check_count => payment.preferred_check_count + 1)
        else
          payment.update(:preferred_check_count => 1)
        end

        # 非终结状态下, 主动查询
        if !payment.completed? && !payment.refunded? && !payment.closed?
          if payment.preferred_check_count <= CHECK_INTERVALS.length
            delay = CHECK_INTERVALS[payment.preferred_check_count - 1]
            Payment.delay_for(delay).check_payment_completed(payment_id)
          else
            # 超时撤消订单
            payment.close
          end
        end
      end
    end

    private
    def do_process(request, options = {})
      result = self.payment_method.generate(self, request, options)
      self.partner_id = result[:partner_id]
      self.out_trade_no = result[:out_trade_no]
      self.preferred_generate_log = result.to_json
      self.preferred_sub_method = result[:sub_method]
      self.save!
      result
    end

    def do_close(close_result)
      begin
        pay_item.update(state: :closed)
        pay_item.order.save
      rescue => e
        log(:do_close, {exception: e})
      end
    end

    #
    # 完成支付，则记录下通知信息，以作后续查询
    #
    def complete(request, result)

      if request.is_a? Hash
        # for directly call on_verify_success
        self.preferred_notify_log = request[:params].to_json
      else
        self.preferred_notify_log = request.params.to_json
      end

      self.preferred_notify_result = result.to_json
      self.save!
      if payment_method.try(:preferred_collection)
        self.shop.collection_wallet.collect(self)
      end
      notify_paid_to_order
    end

    def fail(exception)
      log(:fail, {exception: exception})
    end

    def log(group, params = {})
      Rails.logger.payments.error("[#{group}] #{{payment_id:self.id}.merge(params)}")
    end

    def check_amount
      self.update_column(:workflow_state, :completed) if self.amount == 0
    end

    def rollback_remote_payment
      if closed?
        true
      else
        result = close
        result[:success]
      end
    end

    def refund(options = {})
      # TODO: 退款操作必须人工进行。 (含反结、重新结算、取消订单)
      return false unless payment_method.respond_to?(:refund)

      result = payment_method.refund(self, options)
      if result[:success]
        refund! if may_refund?
        PaymentLog.log(self, event: :refund_success, extra: result[:data].try(:to_json))
        self.order.payment_refunded(self)
        result
      else
        PaymentLog.log(self, event: :refund_error, extra: result[:data].try(:to_json))
        false
      end
    end

    private
    def notify_paid_to_order
      self.order.payment_paid(self)
    end
  end
end
