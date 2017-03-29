#encoding: utf-8
module Ddt
  module Alipay
    class OpenWap < Ddt::Alipay::BaseOpenAlipay

      def self.sub_method_name
        'open_wap'
      end

      def invoke
        super
        # 如果有开放平台的 APP_ID，优先使用新接口
        service_params = wap_pay_params
        rsa_sign(service_params)
        send_request(service_params, {result_format: 'resp'}) do |resp_data|
          case(resp_data.code)
            when '302', '301'
              self.data_type = 'url'
              self.data = resp_data.header['location']
            when '200'
              self.data_type = 'html'
              self.data = resp_data.body.force_encoding('gb2312')
          end
        end
        invoke_result_template
      end

      private
      def wap_pay_params
        {
            app_id: app_id,
            method: 'alipay.trade.wap.pay',
            format: 'JSON',
            return_url: callback_url,
            charset: 'utf-8',
            charset: 'utf-8',
            sign_type:  'RSA',
            timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            version: '1.0',
            notify_url: notify_url,
            biz_content: biz_content.to_json
        }
      end

      def biz_content
        {
            body: "订单: #{order.number}",
            subject: "订单: #{order.number}",
            out_trade_no: out_trade_no,
            timeout_express: timeout_express,
            total_amount: payment.amount,
            product_code: 'QUICK_WAP_PAY'
        }
      end

    end
  end
end