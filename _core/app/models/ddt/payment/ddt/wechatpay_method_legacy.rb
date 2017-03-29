# encoding: utf-8

#
# 本类移值自旧版本，以图稳定性。
# 新注册的微信支付门店不能使用此接口。
# v2.7
#
module Ddt
  class WechatpayMethodLegacy < WechatpayMethod
    preference :appid, :string
    preference :paySignKey, :string
    preference :partnerId, :string
    preference :partnerKey, :string

    validates :preferred_appid, :preferred_paySignKey, :preferred_partnerId, :preferred_partnerKey, presence: true, if: :active?

    before_validation do 
      self.preferred_appid = self.preferred_appid.gsub(' ', '') if self.preferred_appid
      self.preferred_paySignKey = self.preferred_paySignKey.gsub(' ', '') if self.preferred_paySignKey
      self.preferred_partnerId = self.preferred_partnerId.gsub(' ', '') if self.preferred_partnerId
      self.preferred_partnerKey = self.preferred_partnerKey.gsub(' ', '') if self.preferred_partnerKey
    end

    #
    # 生成 js api 所需要的参数
    #
    def generate(payment, request, options = {})
      out_trade_no = generate_out_trade_no(payment)
      pay_params = {
          :appId => preferred_appid,
          :timeStamp => Time.now.to_i.to_s,
          :nonceStr => SecureRandom.uuid.to_s,
          :package => build_package_str(payment, request, out_trade_no, options),
          :signType => 'SHA1'
      }
      pay_params[:paySign] = paySign(pay_params, [:appId, :timeStamp, :nonceStr, :package])
      return {
          partner_id: preferred_partnerId,
          out_trade_no: out_trade_no,
          method: 'wechatpay',
          version: 'legacy',
          data_type: 'JSAPI',
          data: pay_params
      }
    end

    def notify(payment, request)
      @body_xml = request.body.read
      @notify_xml = Hash.from_xml(@body_xml).to_options[:xml].to_options
      appId = @notify_xml[:AppId]
      verify = true
      if preferred_appid != appId
        verify = false
      else
        body = {
            :appid=> @notify_xml[:AppId],
            :appkey=> preferred_paySignKey,
            :timestamp=> @notify_xml[:TimeStamp],
            :noncestr=> @notify_xml[:NonceStr],
            :openid=> @notify_xml[:OpenId],
            :issubscribe=> @notify_xml[:IsSubscribe]
        }
        verify = @notify_xml[:AppSignature] == Digest::SHA1.hexdigest(body.sort.map{|field| field.join("=")}.join("&"))
      end

      result = {
          verify: verify,
          content_type: 'text/plain',
          content: verify ? 'success' : 'fail'
      }
    end

    private

    #
    # 构建商品包
    #
    def build_package_str(payment, request, out_trade_no, options)
      package_hash = {
          :bank_type => 'WX',               # 银行通道类型
          :body => "支付#{payment.id}",     # 商品描述
          # :attach                        # 附加数据，原样返回
          :partner => preferred_partnerId,  # 财付通门店号
          :out_trade_no => out_trade_no,    # 门店号
          :total_fee => yuan_to_cent(payment.amount), # 订单总金额，单位为分
          :fee_type => 1,
          :notify_url => Ddt::Payment::notify_url(payment, request),
          :spbill_create_ip => remote_ip(request),
          # :time_start
          # :time_expire
          # :transport_fee
          # :product_fee
          # :goods_tag
          :input_charset => 'UTF-8'
      }

      string1 = package_hash.sort.map { |k, v| "#{k}=#{v.to_s}" }.join('&')
      stringSignTemp = [string1, "key=#{preferred_partnerKey}"].join('&')
      signValue = Digest::MD5.hexdigest(stringSignTemp).upcase!

      # 虽然不知原来为什么这么做，但保持逻辑总可以让程序运行起来
      # package_url_encode_hash = {}
      # ActionController::Parameters.new(package_hash).except(:body, :notify_url).each do |k, v|
      #   package_url_encode_hash[k] = url_encode(v.to_s)
      # end
      # package_url_encode_hash[:body] = package_hash[:body]
      # package_url_encode_hash[:notify_url] = package_hash[:notify_url]
      # string2 = package_url_encode_hash.to_query
      string2 = package_hash.sort.map{|k,v| "#{k}=#{url_encode(v.to_s)}"}.join('&')
      [string2, "sign=#{signValue}"].join('&')
    end

    #
    # 计算签名
    #
    def paySign(params, permits = nil)
      sign_params = ActionController::Parameters.new(params)
      unless permits.nil?
        sign_params = sign_params.permit(permits)
      end
      sign_params[:appkey] = preferred_paySignKey
      query = sign_params.sort.map { |k, v| "#{k.downcase}=#{v}" }.join('&')
      Digest::SHA1.hexdigest(query)
    end

  end
end