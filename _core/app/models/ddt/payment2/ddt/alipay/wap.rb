#encoding: utf-8
module Ddt
  module Alipay
    class Wap < Ddt::Alipay::Base

      def self.sub_method_name
        'wap'
      end

      def invoke
        super
        self.data_type = 'url'
        self.data = wap_url
        invoke_result_template
      end

      def notify
        ::Alipay::Wap::Notify.verify?(notify_params)
      end

      private

      def wap_url
        o = {
            :req_data => {
                :seller_account_name => self.email,
                :out_trade_no  => self.out_trade_no,         # 20130801000001
                :subject       => self.subject,   # Writings.io Base Account x 12
                :total_fee     => "#{self.payment.amount}",
                :notify_url    => self.notify_url, # https://writings.io/orders/20130801000001/alipay_notify
                :call_back_url => self.callback_url  # https://writings.io/orders/20130801000001
            }
        }
        token = ::Alipay::Wap::Service.trade_create_direct_token(o)
        ::Alipay::Wap::Service.auth_and_execute_url(request_token: token)
      end

    end
  end
end