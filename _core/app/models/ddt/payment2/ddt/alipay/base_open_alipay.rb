#encoding: utf-8
module Ddt
  module Alipay
    # alipay.trade.pay 当面付
    class BaseOpenAlipay < Ddt::Alipay::Base

      def notify
        params = notify_params
        sign = params.delete('sign')
        params.delete('sign_type')
        decoded_sign = Base64.decode64(sign)
        string = params.sort.select{|k,v| k.present? and v.present?}.map do |key, value|
          "#{key}=#{value.to_s}"
        end.join('&')

        rsa = OpenSSL::PKey::RSA.new(Ddt::AlipayMethod::ALIPAY_RSA_PUBLIC_KEY)
        verified = true
        unless rsa.verify('sha1', decoded_sign, string)
          unless rsa.verify('sha1', decoded_sign, string.gsub(/\\\//, '/'))
            verified = false
          end
        end

        if verified
          if params['trade_status'] == 'TRADE_SUCCESS' and params['out_trade_no'] == self.payment.out_trade_no
            # may success, send request to follow url with notify_id
            # https://mapi.alipay.com/gateway.do?service=notify_verify&partner=2088002396712354&notify_id=RqPnCoPT3K9%252Fvwbh3I%252BFioE227%252BPfNMl8jwyZqMIiXQWxhOCmQ5MQO%252FWd93rvCB%252BaiGg
            notify_id = params['notify_id']
            confirm = self.confirm(notify_id)
            return 'true' == confirm
          end
        end
        return false
      end

      def query
        service_params = partial_common_params.merge({
                                                         method: 'alipay.trade.query',
                                                         version: '1.0',

                                                         biz_content: {
                                                             out_trade_no: self.out_trade_no
                                                         }.to_json
                                                     })

        rsa_sign(service_params)

        send_request(service_params) do |resp_data|
          resp_data0 = resp_data.to_options[:alipay_trade_query_response].to_options
          Rails.logger.payments.info("[query] alipay payment##{self.payment.id}: #{resp_data0}")
          if (resp_data0[:trade_status] == 'TRADE_CLOSED')
            self.payment.close
            false
          else
            resp_data0[:trade_status] == 'TRADE_SUCCESS'
          end

        end
      end

      def close
        service_params = partial_common_params.merge({
                                                         method: 'alipay.trade.cancel',
                                                         version: '1.0',
                                                         biz_content: {
                                                             out_trade_no: self.out_trade_no
                                                         }.to_json
                                                     })
        rsa_sign(service_params)

        result = {}
        send_request(service_params) do |resp_data|
          resp_data0 = resp_data.to_options[:alipay_trade_cancel_response].to_options
          retry_flag = resp_data0[:retry_flag]
          if retry_flag == 'N'
            result.merge!({
                              success: true,
                              message: resp_data0[:msg],
                              data: resp_data0
                          })
          else
            result.merge!({
                              success: false,
                              message: resp_data0[:msg],
                              data: resp_data0
                          })
          end
          return result
        end
      end

      protected

      def partial_common_params
        {
            app_id: self.app_id,
            charset: 'utf-8',
            sign_type:  'RSA',
            timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S")
        }
      end

      def send_request(service_params, options = {result_format: 'json'})
        uri = URI('https://openapi.alipay.com/gateway.do')
        uri.query = URI.encode_www_form(service_params)

        Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          http.open_timeout = 5
          http.read_timeout = 10
          req = Net::HTTP::Get.new(uri, initheader = {'Content-Type' => 'application/x-www-form-urlencoded;charset=utf-8'})
          resp = http.request(req)

          case (options[:result_format])
            when 'raw'
              resp_data = resp.body
            when 'resp'
              resp_data = resp
            else
              resp_data = JSON.parse(resp.body)
          end

          return yield resp_data
        end
      end

      def send_raw_request(uri, params)
        uri = URI(uri)
        uri.query = URI.encode_www_form(params)

        Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          http.open_timeout = 5
          http.read_timeout = 10
          req = Net::HTTP::Get.new(uri, initheader = {'Content-Type' => 'application/x-www-form-urlencoded;charset=utf-8'})
          resp = http.request(req)
          return yield resp.body
        end
      end

      def rsa_sign(params)
        query = params.sort.select{|k,v| k.present? and v.present?}.map do |key, value|
          "#{key}=#{value.to_s}"
        end.join('&')

        private_key = OpenSSL::PKey::RSA.new(self.rsa_pri_key)
        sign = Base64.encode64(private_key.sign('sha1', query))

        params.merge!(
            'sign'      => sign
        )
      end

      def confirm(notify_id)
        confirm_params = {
            service: 'notify_verify',
            partner: self.pid,
            notify_id: notify_id
        }
        PaymentLog.log(self.payment, event: :alipay_confirm_params, extra: confirm_params.to_json)
        send_raw_request('https://mapi.alipay.com/gateway.do', confirm_params) do |data|
          data
        end
      end

    end
  end
end
