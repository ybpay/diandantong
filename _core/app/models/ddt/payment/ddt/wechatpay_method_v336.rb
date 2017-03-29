# encoding: utf-8
#
# 基于微信支付接口文档 3.3.6 实现的统一支付接口
#
module Ddt
  class WechatpayMethodV336 < WechatpayMethod

    #======================================================================
    # 定义字段
    #======================================================================

    preference :sl_mode, :boolean, default: false # 是否服务商模式
    preference :custom_sl_mode, :boolean, default: false # 自定义代理商模式， 默认代理商是点单通

    # 激活代理商模式
    def active_sl_mode?
      self.active? and self.preferred_sl_mode == true
    end

    def default_sl_mode?
      self.active? and self.preferred_sl_mode == true and self.preferred_custom_sl_mode == false
    end

    def custom_sl_mode?
      self.active? and self.preferred_sl_mode == true and self.preferred_custom_sl_mode == true
    end

    # 激活非代理商模式
    def active_non_sl_mode?
      self.active? and self.preferred_sl_mode != true
    end

    def validate_base_options?
      self.active? and ( self.preferred_sl_mode == false or self.preferred_custom_sl_mode == true)
    end

    # 以下为非服务商模式需要填写的
    preference :gonghao_open_id, :string  # 公众帐号原始 ID
    preference :appid, :string
    preference :appSecret, :string
    preference :mch_id, :string # 商户 ID
    preference :paySignKey, :string # API 键

    validates :preferred_gonghao_open_id, gonghao: true, if: :validate_base_options?
    validates :preferred_appid, format: /\A\w{18}\Z/, presence: true, if: :validate_base_options?
    validates :preferred_appSecret, format: /\A\w{32}\Z/, presence: true, if: :validate_base_options?
    validates :preferred_mch_id, format: /\A\d{8,10}\Z/, presence: true, if: :validate_base_options?
    validates :preferred_paySignKey, length: 32..32, presence: true, if: :validate_base_options?

    # 以下为服务商模式需要填写的
    preference :sub_appid, :string # 子商户 appid
    preference :sub_mch_id, :string # 子商户 ID

    validates :preferred_sub_appid, format: /\A\w{18}\Z/, presence: true, if: :active_sl_mode?
    validates :preferred_sub_mch_id, format: /\A\d{8,10}\Z/, presence: true, if: :active_sl_mode?

    # format correction
    before_validation do
      self.preferred_appid = self.preferred_appid.gsub(' ', '') if self.preferred_appid
      self.preferred_appSecret = self.preferred_appSecret.gsub(' ', '')  if self.preferred_appSecret
      self.preferred_gonghao_open_id = self.preferred_gonghao_open_id.gsub(' ', '') if self.preferred_gonghao_open_id
      self.preferred_mch_id = self.preferred_mch_id.gsub(' ', '') if self.preferred_mch_id
      self.preferred_paySignKey = self.preferred_paySignKey.gsub(' ', '') if self.preferred_paySignKey

      self.preferred_sub_appid = self.preferred_sub_appid.gsub(' ', '') if self.preferred_sub_appid
      self.preferred_sub_mch_id = self.preferred_sub_mch_id.gsub(' ', '') if self.preferred_sub_mch_id
    end

    %w(gonghao_open_id appid appSecret mch_id paySignKey).each do |key|
      define_method key.to_sym do
        self.default_sl_mode? ? Ddt::WechatpaySl.send(key) : self.send("preferred_#{key}")
      end
    end

    %w(sub_appid sub_mch_id).each do |key|
      define_method key.to_sym do
        self.active_sl_mode? ? self.send("preferred_#{key}") : nil
      end
    end

    #
    # https://api.mch.weixin.qq.com/pay/unifiedorder
    # 统一接口，可授受 JSAPI/NATIVE/APP下单
    # NATIVE 支付返回二维码 code_url
    # JSAPI 下单前需要调用登陆授权接口获取用户的 openid
    #
    # 使用 JSAPI 时，如果不通过 options 传入对应于支付帐户的 openid，
    # 或者不存在 cookies[cookie_open_id_index]
    # 会抛出一个用于获取 openid 的异常
    #
    def generate(payment, request, options = {})
      trade_type = options[:trade_type] || 'JSAPI'
      check_args_method = "check_args_for_#{trade_type}"
      send(check_args_method, payment, request, options) if respond_to?(check_args_method, true)

      case trade_type
        when 'JSAPI', 'NATIVE'
          pay_params = build_uniorder_params(payment, request, options)
          data = invoke_unifiedorder_api(pay_params, payment)
          result = build_generate_result(pay_params[:out_trade_no], data, payment)
        when 'MICROPAY'
          # cache the variable for later use
          pay_params = build_micropay_params(payment, request, options)
          result = {
              partner_id: mch_id,
              out_trade_no: pay_params[:out_trade_no],
              data_type: 'processing',
              data: '正在处理支付请求'
          }
          RequestStore.store[:payment] = payment
          RequestStore.store[:pay_params] = pay_params
          RequestStore.store[:result] = result
      end
      result
    end

    def cookie_open_id_index
      #修改时慎重
      "ddt-openid-#{self.shop_id}-#{self.appid}"
    end

    def notify(payment, request)
      data = request.params[:xml]
      raise 'verify sign fail' unless verify(data)
      raise 'return_code fail' unless data[:return_code] == 'SUCCESS'
      raise 'result_code fail' unless data[:result_code] == 'SUCCESS'
      raise 'out_trade_no not match' unless data[:out_trade_no] == payment.out_trade_no
      {
          :verify => true,
          :content_type => 'text/plain',
          :content => 'success'
      }
    end

    #
    # 此方法设计于内部调用，但为了测试方便，放到公共方法中
    # 获取 code 的 URI
    #
    def oauth_url(redirect_uri = nil, request = nil)
      if redirect_uri.nil?
        # 因为 angular js 的路径前缀固定，可以如此计算出首页的位置
        # 然后从首页按 state 作跳转
        # base = request.url
        base = "#{request.protocol}#{Rails.application.default_url_options[:host]}#{request.fullpath}"
        last = base.index('?')
        redirect_uri = "#{base[0...last]}?_dispatch_action=continue_wechatpay_v336&payment_id=#{self.id}"
      end
      WeixinApi.oauth_url(self.appid, URI.encode(redirect_uri), :code, :snsapi_base, 'A001')
    end

    #
    # 因为微信服务器即时支付处理，先把状态变更过来，再通知微信进行支付操作
    #
    def after_pending(from, to, event, request, options)
      if options[:trade_type] == 'MICROPAY'
        payment = RequestStore.store[:payment]
        pay_params = RequestStore.store[:pay_params]
        result = RequestStore.store[:result]

        # 如果需要用户输入密码，result_code 返回 NEED_PASSWORD
        # 然后需要主动查询支付是否完成
        data = invoke_micropay_api(pay_params, payment)
        result[:data_type] = 'result_code'
        result[:data] = data[:result_code]

        # 如果微信支付不需要密码，是同步完成的，所以需要立即调用校验成功接口
        if result[:data] == 'SUCCESS'
          payment.on_verify_success
        elsif data[:err_code] == 'USERPAYING'
          result[:data] = 'USERPAYING'
        end
        true
      end
    end

    #
    # 可以用以查询订单是否支付成功，如果支付成功，返回 true，否则返回 false
    #
    def query(payment)
      params = {
          appid: appid,
          mch_id: mch_id,
          # transaction_id: 0, # 微信的订单号，优先使用
          out_trade_no: payment.out_trade_no, # 商户系统内部的订单号，当没提供transaction_id时需要传这个。
          nonce_str: SecureRandom.uuid.to_s[0...32], #随机字符串，不长于32位。推荐随机数生成算法
      }
      if self.active_sl_mode?
        params[:sub_appid] = sub_appid
        params[:sub_mch_id] = sub_mch_id
      end
      params[:sign] = sign(params)

      resp = HTTParty.post(
          'https://api.mch.weixin.qq.com/pay/orderquery',
          :body => params.to_xml(:root => :xml, :dasherize => false)
      )
      data = Hash.from_xml(resp.body).to_options[:xml].to_options

      check_response(params, data)
      if data[:trade_state] == 'PAYERROR' || data[:trade_state] == 'CLOSED' || data[:trade_state] == 'REVOKED'
        payment.close
      end
      data[:trade_state] == 'SUCCESS'
    end

    def close(payment)
      params = {
          appid: appid,
          mch_id: mch_id,
          out_trade_no: payment.out_trade_no,
          nonce_str: SecureRandom.uuid.to_s[0...32]
      }
      params[:sign] = sign(params)
      resp = HTTParty.post(
          'https://api.mch.weixin.qq.com/pay/closeorder',
          :body => params.to_xml(:root => :xml, :dasherize => false)
      )
      data = Hash.from_xml(resp.body).to_options[:xml].to_options
      result = {}
      if !verify(data)
        success = false
        message = 'verify sign fail'
      elsif data[:return_code] != 'SUCCESS'
        success = false
        message = 'return_code fail'
      else
        success = data[:result_code] == 'SUCCESS'
        message = success ? data[:return_msg] : data[:err_code_des]
      end
      {
          success: success,
          message: message,
          data: data
      }
    end

    # 发送错误邮件
    def send_appid_or_appsecret_error_email
      shop = self.shop
      ac = shop.accounts.first
      ck = "wechatpay_method_appid_or_appsecret_invalid_#{self.appid}_notification_at"
      last_notification_at = Rails.cache.fetch(ck) do
        1.days.ago # 默认值使发送邮件触发
      end
      # 每 30 分钟发送一封
      if last_notification_at < 30.minutes.ago
        body = <<-EMAILBODY
您的微信支付设置的App secret过期, 请到点单通系统后台更新。
#{Ddt::Core::Engine.routes.url_helpers.backend_shop_wechatpay_method_v336s_url(shop, host: Rails.application.default_url_options[:host])}
        EMAILBODY
        NotificationMailer.notify(ac.email, "您的微信支付设置的App secret过期, 请到点单通后台更新",body, shop).deliver
        Rails.cache.write(ck, Time.now)
      end
    end

    private

    def sign(params)
      string1 = params.select{|k, v| v.present? }.sort.map {|k,v| "#{k}=#{v.to_s}"}.join('&')
      Digest::MD5.hexdigest([string1,"key=#{paySignKey}"].join('&')).upcase!
    end

    def verify(params)
      verify_params = params.clone
      sign = verify_params[:sign]
      verify_params.except!(:sign)
      return sign(verify_params) == sign
    end

    #
    # 当 trade_type 为 JSAPI 时，要求 openid 是否存在
    #
    def check_args_for_JSAPI(payment, request, options)
      unless options[:openid].present? or request.cookies[cookie_open_id_index].present?
        ex = Ddt::NoWechatpayOpenIdException.new(self)
        ex.message = init_result({
                                     data_type: 'oauth2_url',
                                     data: oauth_url(nil, request)
                                 }).to_json
        raise ex
      end
    end

    def build_common_params(payment, request, options)
      out_trade_no = generate_out_trade_no(payment)
      result = {
          appid: appid,
          mch_id: mch_id,
          # device_info:            # 微信支付分配的终端设备号
          device_info: payment.branch_id, # 终端设备号(门店号或收银设备ID)，默认请传"WEB"
          nonce_str: SecureRandom.uuid.to_s[0...32], #
          # sign: # 签名
          body: '商品描述', # 商品描述
          # attach: # 附加数据,原样返回
          # 门店系统内部的订单号 ,32 个字符内 、可包含字母 ,确保 在门店系统唯一 , 详细说明见 7.3 节第四项
          out_trade_no: out_trade_no,
          total_fee: yuan_to_cent(payment.amount), # 订单总金额,单位为分,不 能带小数点
          spbill_create_ip: remote_ip(request), # 订单生成的机器 IP
          # 订单生成时间,格式 为 yyyyMMddHHmmss,如 2009 年 12月25日9点10分10秒表 示为 20091225091010。时区 为 GMT+8 beijing。该时间取 自门店服务器
          # time_start
          # 订单失效时间,格式 为 yyyyMMddHHmmss,如 2009 年 12月27日9点10分10秒表 示为 20091227091010。时区 为 GMT+8 beijing。该时间取 自门店服务器
          # time_expire
          # 商品标记,该字段不能随便 填,不使用请填空,使用说 明详见第 5 节
          # goods_tag
      }

      if self.active_sl_mode?
        result[:sub_appid] = sub_appid
        result[:sub_mch_id] = sub_mch_id
      end
      result
    end

    def build_uniorder_params(payment, request, options)
      commons = build_common_params(payment, request, options)

      pay_params = {
          notify_url: Ddt::Payment::notify_url(payment, request),
          trade_type: 'JSAPI', # JSAPI、NATIVE、APP
          # openid:
          # product_id: payment.id
      }.merge(commons).merge(options).select{ |k|
        %w(appid mch_id device_info nonce_str sign body attach out_trade_no total_fee spbill_create_ip time_start time_expire goods_tag notify_url trade_type openid product_id sub_appid sub_mch_id sub_openid).include? k.to_s
      }

      case pay_params[:trade_type]
        when 'JSAPI'
          # 用户在门店 appid 下的唯一 标识, trade_type 为 JSAPI 时,此参数必传,获取方式 见表头说明。
          unless pay_params[:openid].present?
            if request.cookies[cookie_open_id_index].present?
              pay_params[:openid] = request.cookies[cookie_open_id_index]
              # pay_params[:sub_openid] = pay_params[:openid] #FIXME 暂时这样设置
            else
              raise 'missing openid'
            end
          end
        when 'NATIVE'
          # 只在 trade_type 为 NATIVE 时需要填写。此 id 为二维码 中包含的商品 ID,门店自行 维护。
          pay_params[:product_id] = payment.id
      end
      pay_params[:sign] = sign(pay_params)

      pay_params
    end

    def build_micropay_params(payment, request, options)
      commons = build_common_params(payment, request, options)
      pay_params = {
          auth_code: options[:auth_code] # 授权码
      }.merge(commons).merge(options).select{ |k|
        %w(appid mch_id device_info nonce_str sign body detail attach out_trade_no total_fee fee_type spbill_create_ip time_start time_expire goods_tag auth_code sub_openid sub_mch_id sub_appid).include? k.to_s
      }
      pay_params[:sign] = sign(pay_params)
      pay_params
    end


    #
    # 调用统一支付接口，获取后续调用的参数
    # JSAPI: prepay_id
    # NATIVE: code_url
    #
    def invoke_unifiedorder_api(pay_params, payment)
      PaymentLog.log(payment, event: 'wechat_unifiedorder', extra: pay_params.to_json)
      resp = HTTParty.post(
          'https://api.mch.weixin.qq.com/pay/unifiedorder',
          :body => pay_params.to_xml(:root => :xml, :dasherize => false)
      )
      data = Hash.from_xml(resp.body).to_options[:xml].to_options

      check_response(pay_params, data)
      data
    end

    def invoke_micropay_api(pay_params, payment)
      PaymentLog.log(payment, event: 'wechat_micropay', extra: pay_params.to_json)
      # 公众账号ID	appid	String(32)	是	wx8888888888888888	微信分配的公众账号ID
      # 商户号	mch_id	String(32)	是	1900000109	微信支付分配的商户号
      # 设备号	device_info	String(32)	否	013467007045764	终端设备号(商户自定义，如门店编号)
      # 随机字符串	nonce_str	String(32)	是	5K8264ILTKCH16CQ2502SI8ZNMTM67VS	随机字符串，不长于32位。推荐随机数生成算法
      # 签名	sign	String(32)	是	C380BEC2BFD727A4B6845133519F3AD6	签名，详见签名生成算法
      # 商品描述	body	String(32)	是	Ipad mini  16G  白色	商品或支付单简要描述
      # 商品详情	detail	String(8192)	否	Ipad mini  16G  白色	商品名称明细列表
      # 附加数据	attach	String(127)	否	说明	附加数据，在查询API和支付通知中原样返回，该字段主要用于商户携带订单的自定义数据
      # 商户订单号	out_trade_no	String(32)	是	1217752501201407033233368018	商户系统内部的订单号,32个字符内、可包含字母, 其他说明见商户订单号
      # 总金额	total_fee	Int	是	888	订单总金额，单位为分，只能为整数，详见支付金额
      # 货币类型	fee_type	String(16)	否	CNY	符合ISO 4217标准的三位字母代码，默认人民币：CNY，其他值列表详见货币类型
      # 终端IP	spbill_create_ip	String(16)	是	8.8.8.8	调用微信支付API的机器IP
      # 交易起始时间	time_start	String(14)	否	20091225091010	订单生成时间，格式为yyyyMMddHHmmss，如2009年12月25日9点10分10秒表示为20091225091010。详见时间规则
      # 交易失效时间	time_expire	String(14)	否	20091227091010	订单失效时间，格式为yyyyMMddHHmmss，如2009年12月27日9点10分10秒表示为20091227091010。详见时间规则
      # 商品标记	goods_tag	String(32)	否	 	商品标记，代金券或立减优惠功能的参数，说明详见代金券或立减优惠
      # 授权码	auth_code	String(128)	是	120061098828009406	扫码支付授权码，设备读取用户微信中的条码或者二维码信息
      resp = HTTParty.post(
          'https://api.mch.weixin.qq.com/pay/micropay',
          :body => pay_params.to_xml(:root => :xml, :dasherize => false)
      )
      data = Hash.from_xml(resp.body).to_options[:xml].to_options

      error_message = nil
      error_message = "verify sign fail, data=#{data}" unless verify(data)
      error_message = "return_code fail, data=#{data}" unless data[:return_code] == 'SUCCESS'
      # TODO 如果 result_code 是 FAIL 且 err_code 是 USERPAYING 表示需要用户输入密码。
      # 等待5秒，然后调用被扫订单结果查询API，查询当前订单的不同状态，决定下一步的操作。
      case data[:result_code]
        when 'SUCCESS'
        else
          error_message = "result_code fail, data=#{data}" unless data[:err_code] == 'USERPAYING'
      end
      if error_message.present?
        raise Ddt::PaymentException.new(
                  error_message,
                  {
                      params: pay_params,
                      response: data,
                  })
      end

      data
    end

    #
    # 生成用于调用支付接口的数据结构
    #
    def build_generate_result(out_trade_no, data, payment)
      result = init_result({
          partner_id: mch_id,
          out_trade_no: out_trade_no
      })

      case data[:trade_type]
        when 'NATIVE'
          scene = self.shop.pay_qr_code_scenes.create(
              builtin: true,
              owner: payment,
              name: "NATIVE 微信支付 #{payment.id}",
              preferred_pay_url: data[:code_url]
          )
          result.merge! data_type: 'NATIVE', data: data[:code_url], qr_code_url: scene.url.url
        when 'JSAPI'
          jsapi_data = {
              :appId => appid,
              :timeStamp => Time.now.to_i.to_s,
              :nonceStr => data[:nonce_str],
              :package => "prepay_id=#{data[:prepay_id]}",
              :signType => 'MD5'
          }
          jsapi_data[:paySign] = sign(jsapi_data)
          result.merge! data_type: 'JSAPI', data: jsapi_data
        when 'MICROPAY'
          result.merge!({
            data_type: 'processing',
            data: '正在处理支付请求'
          })
      end

      result
    end

    #
    # 初始化返回结果，统一参数
    #
    def init_result(params = {})
      {
          method: 'wechatpay',
          version: '3.3.6'
      }.merge(params)
    end

    def check_response(params, data)
      error_message = nil
      error_message = "verify sign fail, data=#{data}" unless verify(data)
      error_message = "return_code fail, data=#{data}" unless data[:return_code] == 'SUCCESS'
      error_message = "result_code fail, data=#{data}" unless data[:result_code] == 'SUCCESS'
      if error_message.present?
        raise Ddt::PaymentException.new(
                  error_message,
                  {
                      params: params,
                      response: data,
                  })
      end

      true
    end

  end
end
