#encoding: utf-8
module Ddt
  module Alipay
    class QrCodeLegacy < Ddt::Alipay::Base

      attr_accessor :qr_code_url

      def self.sub_method_name
        'qr_code_legacy'
      end

      def invoke
        super
        generate_qr_code_url_legacy_internal
        invoke_result_template
      end

      private
      #
      # return: data_type = 'qr_code', data = [url], qr_code_url = []image_url]
      # 仅用于 web 和 wap 接口的遗留方式。以后有可能全部使用 uniprepay 方式生成
      #
      def generate_qr_code_url_legacy_internal
        # 生成二维码
        qr_code_req_params = {
            partner: self.pid,
            _input_charset: 'utf-8',
            timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            service: 'alipay.mobile.qrcode.manage',
            method: 'add',
            biz_type: 10,
            biz_data: {
                trade_type: '1',
                need_address: 'F',
                goods_info: {
                    id: self.out_trade_no,
                    name: "订单 #{self.out_trade_no}",
                    price: self.payment.amount
                },
                notify_url: self.notify_url
            }.to_json
        }

        # resp = open("#{Alipay::Service::GATEWAY_URL}?#{Alipay::Service.query_string(qr_code_req_params)}").read
        resp = open(::Alipay::Service.request_uri(qr_code_req_params)).read
        #
        # 如果 Alipay 有问题，会返回如下数据
        # "<alipay><is_success>F</is_success><error>ILLEGAL_PARTNER</error></alipay>"
        #
        xml_data = Hash.from_xml(resp)
        if xml_data['alipay']['is_success'] == 'F'
          raise xml_data['alipay']['error']
        else
          result = Hash.from_xml(resp)['alipay']['response']['alipay']

          self.data_type = 'qr_code'
          self.data = result['qrcode']
          self.qr_code_url = result['qrcode_img_url']
          return invoke_result_template
        end
      end

      def notify
        params = notify_params
        if ::Alipay::Sign.verify?(params)
          data = Hash.from_xml(params['notify_data'])
          if data['notify']['trade_status'] == 'TRADE_SUCCESS'
            return true
          end
        end
        return false
      end

    end
  end
end