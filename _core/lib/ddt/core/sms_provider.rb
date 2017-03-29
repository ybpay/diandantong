#encoding: utf-8
require 'faraday'

module Ddt
  # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  module SmsProvider
    # 创蓝
    class Cl2009
      def self.load_config
        YAML.load_file("#{Rails.root}/config/cl2009.yml")[Rails.env]
      end

      def self.send(mobile, msg)
        if Rails.env.development?
          return [true, 11111]
        end
        config = self.load_config.symbolize_keys # { account pswd host }
        url = "/msg/HttpBatchSendSM"
        # url = "/msg/HttpVarSM"
        query_params = {
          :account    => config[:account],
          :pswd       => config[:pswd],
          :mobile     => mobile,
          :msg        => msg,
          :needstatus => true,
          # :product => 产品ｉｄ
          # :extno => 拓展码
        }
        uri = URI.parse(config[:host] + url)
        http = Net::HTTP.new(uri.host,uri.port)
        http.open_timeout = 10
        http.read_timeout = 10
        req = Net::HTTP::Post.new(uri.request_uri)
        req.set_form_data(query_params)
        response = http.request(req)
        Rails.logger.info "创蓝短信 mobile: [#{mobile}] body : #{response.body}"
        status = response.body.split("\n")[0].split(',')[1]
        if status == '0'
          msgid = response.body.split("\n")[1]
          [true, msgid]
        else
          [false, self.error_info(status)]
        end
      end

      def self.error_info(status)
        {
          '101' => "无此用户",
          '102' => "密码错",
          '103' => "提交过快",
          '104' => "系统忙",
          '105' => "敏感短信",
          '106' => "消息长度错",
          '107' => "包含错误的手机号码",
          '108' => "手机号码个数错",
          '109' => "无发送额度",
          '110' => "不在发送时间内",
          '111' => "超出该账户当月发送额度限制",
          '112' => "无此产品， 用户没有订阅该产品",
          '113' => "extno格式错",
          '115' => "自动审核驳回",
          '116' => "签名不合法，未带签名",
          '117' => "IP地址认证错，请求调用的IP地址不是系统登记的IP地址",
          '118' => "用户没有相应的发送权限",
          '119' => "用户已过期",
        }[status]
      end

      def self.test_send
        # Ddt::SmsProvider::Cl2009.test_send
        # 【点单通】{$var}
        send("13402136328", "验证码消息: 123456")
      end
    end
  end

end