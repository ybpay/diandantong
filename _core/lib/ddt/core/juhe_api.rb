#encoding: utf-8
module Ddt
  module JuheApi
    class JuheApiError < ::StandardError; end
    HOST = 'http://apis.juhe.cn'

    class << self

      # 手机号码归属地
      def mobile_address(key, phone)
        get '/mobile/get', {key: key, phone: phone} do |data|
          return nil if data.blank?
          result = data[:result].symbolize_keys
          return result
            ## result:
            # province  string  省份
            # city      string  城市
            # areacode  string  区号
            # zip       string  邮编
            # company   string  运营商
            # card      string  卡类型
        end
      end

      def get(path, params)
        #return get_fake(path, params)
        default_params = {dtype: :json}
        params = default_params.merge!(params)
        body = URI.parse("#{HOST}#{path}?#{params.to_query}").read
        data = ActiveSupport::JSON.decode(body).to_options
        if data[:resultcode] == '200'
          yield data
        else
          raise JuheApiError, "Path: #{path}, Params: #{params}, Response: #{data}"
        end
      end

      def get_fake(path, params)
        # 网页
        default_params = {
          callback: :jQuery18306912736501037046_1447405330417,
          dtype: :jsonp,
          key: :b4b88a8ffc09e2fd3f24251ee19fa168,
          _: 1447405340236
        }
        params = default_params.merge!(params)
        body = URI.parse("#{HOST}#{path}?#{params.to_query}").read
        json = body[0, body.size-1].split('(')[1]
        data = ActiveSupport::JSON.decode(json).to_options
        yield data
      end

    end

  end
end
