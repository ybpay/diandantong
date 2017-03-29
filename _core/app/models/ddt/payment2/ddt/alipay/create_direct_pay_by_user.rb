#encoding: utf-8
module Ddt
  module Alipay
    #
    # 即时到帐交易
    #
    class CreateDirectPayByUser < Ddt::Alipay::Base

      def self.sub_method_name
        'create_direct_pay_by_user'
      end

      def invoke
        super

        # create_direct_pay_by_user
        # Alipay::Service.create_direct_pay_by_user_url({ARGUMENTS}, {OPTIONS})
        self.data_type = 'url'
        self.data = ::Alipay::Service.create_direct_pay_by_user_url(
            out_trade_no: self.out_trade_no,
            subject: self.subject,
            total_fee: self.payment.amount,
            return_url: self.callback_url,
            notify_url: self.notify_url
        )
        invoke_result_template
      end

      def notify
        ::Alipay::Notify.verify?(notify_params)
      end

    end
  end
end