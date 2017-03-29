#encoding:utf-8
module Ddt::BaiduPushClient

  #
  # 推送消息格式
  # {
  #    title: 通知标题
  #    description: 通知内容
  #    custom_content: {
  #       id: 消息 id
  #       shop_id: 门店 id
  #       branch_id: 分店 id
  #       account_id: 当前通知的 account_id
  #       content: 消息内容
  #       event_type: 事件类型
  #       when: 通知时间
  #       category: 消息分组 (决定APP分组)
  #       order_type: 订单类型（仅订单消息）
  #       order_id: 订单ID （仅订单消息）
  #       guest_queue_id: （仅排号消息）
  #       queue_setting_id: （仅排号消息）
  #    }
  # }
  #

  def self.single_device(android_message, channels)
    ios_message = android_to_ios(android_message)
    Rails.logger.info(
        android_message.merge(
            channels: channels.map { |it| [it.os_type, it.channel_id, it.user_id] }
        ));
    begin
      # push_msg(push_type, messages, msg_keys, params = {})
      channels.each do |channel|
        is_android = channel.os_type.to_sym == 'android'.to_sym
        push_msg_params = {
            channel_id: channel.channel_id,
            msg_type: is_android ? 0 : 1,
            msg: (is_android ? android_message : ios_message).to_json, # 消息体，默认消息类型为 '消息'
        }
        push_msg_params[:deploy_status] = Ddt::BaiduPushConfig.ios_deploy_status
        response = conn_post(channel.os_type, push_msg_params)
        Rails.logger.info "body : #{response.body}"
      end
    rescue => e
      Rails.logger.error("#{e.message}\n#{e.backtrace}")
      raise e
    end
  end

  def self.batch_device(android_message, channels)
    Rails.logger.info(
        android_message.merge(
            channels: channels.map { |it| [it.os_type, it.channel_id, it.user_id] }
        ));

    # 分别找出 android 和 ios 的 channel
    android_channels = channels.where(os_type: 'android')
    begin
      if android_channels.present?
        push_msg_params = {
            channel_ids: android_channels.map(&:channel_id).to_json,
            msg_type: 0,
            msg: android_message.to_json # 消息体，默认消息类型为 '消息'
        }
        response = conn_post('android', push_msg_params)
        Rails.logger.info "body : #{response.body}"
      end
    rescue => e
      Rails.logger.error("#{e.message}\n#{e.backtrace}")
      raise e
    end

    ios_channels = channels.where(os_type: 'ios')
    begin
      if ios_channels.present?
        # ios 不支持组播，故使用指单播
        single_device(android_message, ios_channels)
      end
    rescue => e
      Rails.logger.error("#{e.message}\n#{e.backtrace}")
      raise e
    end
  end


  #
  #   content:
  #       id: 消息 id
  #       shop_id: 门店 id
  #       branch_id: 分店 id
  #       account_id: 当前通知的 account_id
  #       content: 消息内容
  #       event_type: 事件类型
  #       when: 通知时间
  #       category: 消息分组 (决定APP分组)
  #       order_type: 订单类型（仅订单消息）
  #       order_id: 订单ID （仅订单消息）
  #       guest_queue_id: （仅排号消息）
  #       queue_setting_id: （仅排号消息）
  #
  def self.build_message(title, desc, content = {})
    {
       title: title,
       description: desc,
       custom_content: content
    }
  end

  private

  # {
  #     "aps": {
  #     "alert":"Message From Baidu Cloud Push-Service",
  #     "sound":"",  //可选
  #     "badge":0,    //可选
  #     },
  #     "key1":"value1",
  #     "key2":"value2"
  # }
  def self.android_to_ios(android_msg)
    ios_msg = {
        "aps" => {
            "alert" => android_msg[:title],
            "badge" => 1,
            "sound" => "default.mp3"
            # "content-available" => 1
        }
    }
    ios_msg.merge!(android_msg[:custom_content])
    ios_msg
  end

  BAIDU_PUSH_HOST = 'http://api.tuisong.baidu.com'
  SINGLE_DEVICE_URL = '/rest/3.0/push/single_device'
  BATCH_DEVICE_URL = '/rest/3.0/push/batch_device'

  # apikey	string	是	应用的api key,用于标识应用,
  # timestamp	number	是	用户发起请求时的unix时间戳。本次请求签名的有效时间为该时间戳向后10分钟
  # sign	string	是	调用参数签名值，与apikey成对出现。用于防止请求内容被篡改, 生成方法请参考：签名算法
  # expires	number	否	用户指定本次请求签名的失效时间。格式为unix时间戳形式，用于防止 replay 型攻击。为保证防止 replay攻击算法的正确有效，请保证客户端系统时间正确
  # device_type	number	否	当一个应用同时支持多个设备平台类型（比如：Android和iOS），请务必设置该参数。其余情况可不设置。具体请参见：device_type参数使用说明

  def self.conn_post(os_type, params)
    params = {
        apikey: Ddt::BaiduPushConfig.send("#{os_type}_api_key"),
        timestamp: Time.new.to_i,
        expires: 10.minutes.since.to_i,
        device_type: os_type.to_sym == :ios ? 4 : 3
    }.merge(params)
    params[:sign] = sign(os_type, params)

    if params[:channel_ids].present?
      uri = URI.parse(BAIDU_PUSH_HOST + BATCH_DEVICE_URL)
    else
      uri = URI.parse(BAIDU_PUSH_HOST + SINGLE_DEVICE_URL)
    end
    http = Net::HTTP.new(uri.host,uri.port)
    http.open_timeout = 10
    http.read_timeout = 10
    req = Net::HTTP::Post.new(
        uri.request_uri,
        initheader = {
            'Content-Type' => 'application/x-www-form-urlencoded;charset=utf-8',
            # BCCS_SDK/3.0 (操作系统版本信息) PHP/5.x.x (SDK名称及版本信息) 其它扩展模块/版本(附加信息)
            # User-Agent: BCCS_SDK/3.0 (Darwin; Darwin Kernel Version 14.0.0: Fri Sep 19 00:26:44 PDT 2014; root:xnu-2782.1.97~2/RELEASE_X86_64; x86_64) PHP/5.6.3 (Baidu Push Server SDK V3.0.0 and so on..) cli/Unknown ZEND/2.6.0
            'User-Agent' => 'BCCS_SDK/3.0 (Darwin; Darwin Kernel Version 14.0.0: Fri Sep 19 00:26:44 PDT 2014; root:xnu-2782.1.97~2/RELEASE_X86_64; x86_64) PHP/5.6.3 (Baidu Push Server SDK V3.0.0 and so on..) cli/Unknown ZEND/2.6.0'
        }
    )
    req.body = params.map{|k,v|"#{k}=#{CGI.escape(v.to_s)}"}.join('&')
    http.request(req)
  end

  def self.sign(os_type, params)
    # sign = MD5( urlencode( $http_method$url$k1=$v1$k2=$v2$k3=$v3$secret_key ));
    secret_key = Ddt::BaiduPushConfig.send("#{os_type}_secret_key")
    Digest::MD5.hexdigest(CGI::escape("POST#{BAIDU_PUSH_HOST}#{params[:channel_ids].present? ? BATCH_DEVICE_URL : SINGLE_DEVICE_URL}#{params.sort.map{|k,v|"#{k.to_s}=#{v.to_s}"}.join}#{secret_key}"))
  end

end
