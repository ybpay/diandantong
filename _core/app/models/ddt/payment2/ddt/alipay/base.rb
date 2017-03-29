#encoding: utf-8
module Ddt
  module Alipay
    class Base
      attr_accessor :pid
      attr_accessor :key
      attr_accessor :email
      attr_accessor :app_id
      attr_accessor :rsa_pri_key

      # the input
      attr_accessor :payment
      attr_accessor :request
      attr_accessor :options
      attr_accessor :order

      # the invoke parameter
      attr_accessor :out_trade_no
      attr_accessor :subject
      attr_accessor :payment_id
      attr_accessor :callback_url
      attr_accessor :request_from
      attr_accessor :notify_url
      attr_accessor :agent_id
      # 超时时间,默认 15 分钟
      attr_accessor :timeout_express

      attr_accessor :dynamic_id_type
      attr_accessor :dynamic_id

      # the configuration object
      attr_accessor :data_type
      attr_accessor :data
      attr_accessor :qr_code_url

      def initialize(payment, request, options = {})
        self.payment = payment
        self.request = request
        self.options = options
        self.order = payment.try(:order)

        self.callback_url = options[:callback_url]
        if request.present?
          self.callback_url = self.callback_url || "http://#{request.host}:#{request.port}/"
        end

        self.out_trade_no = payment.out_trade_no || options[:out_trade_no] || Time.now.strftime("%Y%m%d%H%M%S%s")
        self.subject = options[:subject] || generate_subject
        self.payment_id = payment.id
        self.request_from = options[:request_from] || 'wap'

        self.dynamic_id_type = options[:dynamic_id_type]
        self.dynamic_id = options[:dynamic_id]
        self.timeout_express = options[:timeout_express] || '15m'

      end

      def name
        '支付宝'
      end

      def sub_method_name
        self.class.sub_method_name
      end

      def invoke
        self.notify_url = default_notify_url
      end

      def query
        resp = ::Alipay::Service.single_trade_query({
                                                      service: 'alipay.acquire.query',
                                                      out_trade_no: self.payment.out_trade_no
                                                  }, {
                                                      pid: self.pid,
                                                      key: self.key,
                                                  })
        hash = Hash.from_xml(resp)['alipay'].symbolize_keys
        if hash[:is_success] == 'T'
          response = hash[:response].symbolize_keys[:alipay].symbolize_keys
          if response[:result_code] == 'SUCCESS' and response[:trade_status] == 'TRADE_SUCCESS'
            return true
          end
        end
        return false
      end

      def notify
      end

      def close
        resp = ::Alipay::Service.close_trade(
            {
                out_order_no: self.payment.out_trade_no
            },
            {
                pid: self.pid,
                key: self.key
            }
        )
        hash = Hash.from_xml(resp)['alipay'].symbolize_keys
        if hash[:is_success] == 'T'
          response = hash[:response].symbolize_keys[:alipay].symbolize_keys
          {
              success: true,
              message: response[:error] || 'OK',
              data: hash
          }
        else
          {
              success: false,
              message: hash[:error],
              data: hash
          }
        end
      end

      def rollback

      end

      protected
      def invoke_result_template
        {
            sub_method: self.sub_method_name,
            partner_id: self.pid,
            out_trade_no: self.out_trade_no,
            method: 'alipay',
            data_type: self.data_type,
            data: self.data,
            qr_code_url: self.qr_code_url
        }
      end

      def notify_params
        #
        # 计算签名必须去掉自定义回调参数
        #
        # http://ma-w.diandantong.com:81/oapi/v1/payments/1/notify?request_from=wap&out_trade_no=201410222001231413979283&request_token=requestToken&result=success&trade_no=2014102261487334&sign=1402edd1f3fb30175fa0aa3a524d7393&sign_type=MD5
        #
        notify_params = self.request.params.clone
        %w(id action controller request_from).each do |unsign_key|
          notify_params.delete(unsign_key)
        end
        notify_params
      end

      def generate_subject
        order = self.order
        if order.present?
          subject = "#{order.type_name}订单#{order.number}"
        else
          subject = "支付编号 #{payment.id}"
        end
        subject += '(测试)' if (Rails.env.development? || Rails.env.test?)
        subject
      end

      private
      def default_notify_url
        "http://#{self.request.host}:#{self.request.port}/oapi/v1/payments/#{self.payment.id}/notify?request_from=#{self.request_from}"
      end

      def notify_url_for_request_from(payment, request, request_from)
        "http://#{request.host}:#{request.port}/oapi/v1/payments/#{payment.id}/notify?request_from=#{request_from}"
      end

    end
  end
end