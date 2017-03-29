# encoding:utf-8
# 云通讯相关接口
require 'digest/md5'
module Ddt
  class Cloopen
    SOFT_VERSION = "2013-12-26"
    def self.load_config
      YAML.load_file("#{Rails.root}/config/cloopen.yml")[Rails.env].symbolize_keys
    end

    # 呼叫
    def self.landing_call(to, options={})
      config = self.load_config
      time = Time.now.strftime("%Y%m%d%H%M%S")
      authorization = Base64.strict_encode64([config[:account_sid], time].join(":"))
      sig = Digest::MD5.hexdigest([config[:account_sid], config[:auth_token], time].join).upcase
      url = "/#{SOFT_VERSION}/Accounts/#{config[:account_sid]}/Calls/LandingCalls/?sig=#{sig}"
      body = {
        :appId       => config[:app_id],
        :to          => to,
        :mediaName   => config[:call_media_name],  # 语音文件名称，格式 wav 测试用默认语音：ccp_marketingcall.wav
        :mediaTxt    => options[:text],             # 文本内容
        :displayNum  => config[:call_display_num], # 显示的主叫号码, 显示权限由服务侧控制。
        :playTimes   => options[:play_times],      # 循环播放次数，1－3次，默认播放1次。
        :respUrl     => options[:resp_url],        # 外呼通知状态通知回调地址
        :userData    => options[:user_data],       # 第三方私有数据，可在外呼通知状态通知中获取此参数。
      }
      uri = URI.parse(config[:host] + url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.open_timeout = 10
      https.read_timeout = 10
      https.use_ssl = true
      header = {
        'Accept'         => 'application/json',
        'Content-Type'   => 'application/json;charset=utf-8',
        "Authorization"  => authorization
      }
      req = Net::HTTP::Post.new(uri.request_uri, header)
      req.body = body.to_json
      response = https.request(req)
      Rails.logger.info "云通讯 call: [#{to}] body : #{response.body.force_encoding("UTF-8")}"
      resp = JSON.parse(response.body).symbolize_keys
      if resp[:statusCode] == '000000'
        resp[:LandingCall]["callSid"]
      else
        false
      end
    end

    def self.test_call
      resp_url = Rails.application.routes.url_helpers.ddt_url + "common/cloopen_call_resp"
      landing_call("15715779004", resp_url: resp_url)
    end

  end
end