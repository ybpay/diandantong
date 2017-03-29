#encoding: utf-8
module Ddt
  class Printer
    class Feiyin < Ddt::Printer
      include Ddt::PrinterModelName
      validates_presence_of :member_code, :phone, :api_key

      def print(contents, times=nil, uuid: nil)
        times ||= self.times
        if contents.present?
          contents = contents.is_a?(Array) ? contents : [contents]
          contents.map do |content|
            times.times do |time_count|
              send_to_print(content, time_count+1)
            end
            self.print_records.create!(content: content, times: times)
            true
          end
        end
      end

      def send_to_print(content, time_count)
        query_params = {}
        content = content.gsub(%r{<B>}, "").gsub(%r{</B>}, "")
        content = content.gsub(%r{<M>}, "").gsub(%r{</M>}, "")
        content = content.gsub(%r{<C>}, "").gsub(%r{</C>}, "")
        content = content.gsub(%r{<CB>}, "").gsub(%r{</CB>}, "")
        content = content.gsub(%r{<CM>}, "").gsub(%r{</CM>}, "")
        content = content.gsub(%r{<PCN>[^<]+</PCN>}, "")
        content = content.gsub(%r{<QR>[^<]+</QR>}, "")
        content = content.gsub(%r{<QRI>[^<]+</QRI>}, "")
        apiKey       = self.api_key
        reqTime      = (Time.now.to_f * 1000).to_i
        msgNo        = SecureRandom.uuid #请在validate后也同样添加该号码
        deviceNo     = self.number
        detail       = "当前为第#{time_count}联\n#{content}"
        memberCode   = self.member_code
        content_to_validate_for_free_msg = "#{memberCode}#{detail}#{deviceNo}#{msgNo}#{reqTime}#{apiKey}"
        securityCode_for_free_msg = Digest::MD5.hexdigest(content_to_validate_for_free_msg)
        query_params = {
          :msgDetail    => detail,
          :apiKey       => apiKey,
          :deviceNo     => deviceNo,
          :msgNo        => msgNo,
          :memberCode   => memberCode,
          :reqTime      => reqTime,
          :securityCode => securityCode_for_free_msg,
          :mode         => 2
        }
        retry_with_times do
          uri = URI.parse("http://my.feyin.net/api/sendMsg")
          http = Net::HTTP.new(uri.host,uri.port)
          http.open_timeout = 10
          http.read_timeout = 10
          req = Net::HTTP::Post.new(uri.request_uri)
          req.set_form_data(query_params)
          response = http.request(req)
          Rails.logger.info "body : #{response.body}"
          response
        end
      end

      def is_managed?
        false
      end

    end
  end
end