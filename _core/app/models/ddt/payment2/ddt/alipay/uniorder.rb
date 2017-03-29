#encoding: utf-8
module Ddt
  module Alipay
    class Uniorder < Ddt::Alipay::Base

      def self.sub_method_name
        'uniorder'
      end

      def invoke
        super
        uniorder_params = {
            service: 'alipay.acquire.createandpay',
            partner: self.pid,
            _input_charset: 'utf-8',
            notify_url: self.notify_url,
            out_trade_no: self.out_trade_no,
            subject: self.subject,
            product_code: 'BARCODE_PAY_OFFLINE', # 条码支付参数
            total_fee: self.payment.amount,
            seller_email: self.email,
            dynamic_id_type: self.dynamic_id_type || 'qr_code', # 条码支付参数
            dynamic_id: self.dynamic_id,
            # dynamic_id: 287030330207305277,
        }

        if self.agent_id.present?
          uniorder_params[:extend_params] = {AGENT_ID: self.agent_id}.to_json
        end

        # resp = open("#{Alipay::Service::GATEWAY_URL}?#{Alipay::Service.query_string(uniorder_params)}").read
        resp = open(::Alipay::Service.request_uri(uniorder_params)).read
        xml_data = Hash.from_xml(resp)

        # if Alipay::Sign::verify?(xml_data['alipay']) == false
        #   raise 'verify sign failed'
        if xml_data['alipay']['is_success'] == 'F'
          raise xml_data['alipay']['error']
        else
          response = xml_data['alipay']['response']['alipay']
          if ['ORDER_SUCCESS_PAY_SUCCESS', 'ORDER_SUCCESS_PAY_INPROCESS'].include? response['result_code']
            self.data_type = "result_code"
            self.data = response['result_code']
            return invoke_result_template
          else
            raise "business error: result_code=#{response['result_code']}, detail_error_code=#{response['detail_error_code']}"
          end
        end
      end

      def notify
        params = notify_params
        if ::Alipay::Sign.verify?(params)
          if params['trade_status'] == 'TRADE_SUCCESS' and params['out_trade_no'] == self.payment.out_trade_no
            return true
          end
        end
        return false
      end

    end
  end
end