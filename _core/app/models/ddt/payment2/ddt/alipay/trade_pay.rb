#encoding: utf-8
module Ddt
  module Alipay
    # alipay.trade.pay 统一收单交易支付接口
    class TradePay < Ddt::Alipay::BasePayOnFace

      def self.sub_method_name
        'trade_pay'
      end

      def invoke
        super
        service_params = {
            # common request parameters
            app_id: self.app_id,
            method: 'alipay.trade.pay',
            charset: 'utf-8',
            sign_type:  'RSA',
            timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            version: '1.0',

            biz_content: {
              # business request parameters
              scene: self.dynamic_id_type || 'bar_code', # 条码支付参数
              auth_code: self.dynamic_id, # 用户授权码
              # seller_id: self.pid, # 默认为商户签约账号对应支付宝用户ID
            }.merge(self.partial_biz_content).to_json
        }

        rsa_sign(service_params)

        # if self.agent_id.present?
        #   uniorder_params[:extend_params] = {AGENT_ID: self.agent_id}.to_json
        # end
        Ddt::PaymentLog.log(self.payment, event: :alipay_service_params, extra: service_params.to_json)

        send_request(service_params) do |resp_data|
          resp_data0 = resp_data.to_options[:alipay_trade_pay_response].to_options
          if resp_data0[:code].present? and !%w(10000 10003).include?(resp_data0[:code])
            raise resp_data0.to_s
          else
            self.data_type = 'result_code'
            self.data = resp_data0[:code]
            return invoke_result_template
          end
        end
      end

      def notify
        raise 'unimplements'
      end

    end
  end
end