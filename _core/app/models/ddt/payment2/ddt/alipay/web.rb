#encoding: utf-8
module Ddt
  module Alipay
    class Web < Ddt::Alipay::Base

      def self.sub_method_name
        'web'
      end

      def invoke
        super
        self.data_type = 'url'
        self.data = web_url
        invoke_result_template
      end

      def notify
        ::Alipay::Notify.verify?(notify_params)
      end

      private
      def web_url
        o = {
            :out_trade_no => self.out_trade_no,
            :subject => self.subject,
            :price => payment.amount,
            :quantity => 1,
            :discount => 0,
            :logistics_type => 'DIRECT',
            :logistics_fee => '0',
            :logistics_payment => 'SELLER_PAY',
            :return_url => self.callback_url,
            :notify_url => self.notify_url
        }
        ::Alipay::Service.create_direct_pay_by_user_url(o)
      end

    end
  end
end