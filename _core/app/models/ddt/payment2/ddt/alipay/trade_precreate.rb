#encoding: utf-8
module Ddt
  module Alipay
    # alipay.trade.pay 统一收单交易支付接口
    class TradePrecreate < Ddt::Alipay::BasePayOnFace

      def self.sub_method_name
        'trade_precreate'
      end

      def invoke
        super
        service_params = {
            # common request parameters
            app_id: self.app_id,
            method: 'alipay.trade.precreate',
            charset: 'utf-8',
            sign_type:  'RSA',
            timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            version: '1.0',
            notify_url: default_notify_url,

            biz_content: {
                # business request parameters
            }.merge(self.partial_biz_content).to_json
        }

        rsa_sign(service_params)

        # if self.agent_id.present?
        #   uniorder_params[:extend_params] = {AGENT_ID: self.agent_id}.to_json
        # end
        Ddt::PaymentLog.log(self.payment, event: :alipay_service_params, extra: service_params.to_json)

        send_request(service_params) do |resp_data|
          resp_data0 = resp_data.to_options[:alipay_trade_precreate_response].to_options
          if resp_data0[:code].present? and !%w(10000 10003).include?(resp_data0[:code])
            raise resp_data0.to_s
          else
            scene = self.payment.shop.pay_qr_code_scenes.create(
                builtin: true,
                owner: self.payment,
                name: "支付宝 当面付 #{payment.id}",
                preferred_pay_url: resp_data0[:qr_code]
            )

            self.data_type = 'qr_code'
            self.data = resp_data0[:qr_code]
            self.qr_code_url = scene.url.url
            return invoke_result_template
          end
        end
      end

    end
  end
end