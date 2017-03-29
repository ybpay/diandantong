#encoding:utf-8
module Ddt
  class BaidupayMethod < PaymentMethod

    preference :sp_no, :string
    preference :key, :string

    validates :preferred_sp_no, :preferred_key, presence: true, if: :active?

    BANK_NO_TYPES = %w(11 101 201 301 401 501 601 701 801 1101 1201 13 1901 1902 1903 1904 1905 1906 1907 1908 1909 1910)
    BANK_NO_NAMES = %w(银联 中国工商银行 中国招商银行 中国建设银行 中国农业银行 中信银行 浦东发展银行 中国光大银行 深圳发展银行 交通银行 中国银行 银联在线UPOP 广发银行 中国邮政储蓄银行 中国民生银行 华夏银行 兴业银行 上海银行 上海农商银行 中国银行大额 北京银行 北京农商银行)
    BANK_NO = Hash[BANK_NO_TYPES.zip(BANK_NO_NAMES)]

    before_validation do
      if active?
        [:sp_no, :key].each do |it|
          attr_name = "preferred_#{it}"
          attr_val = send(attr_name)
          send("#{attr_name}=", attr_val.gsub(' ', '')) if attr_val.present?
        end
      end
    end

    def name
      '百度钱包'
    end


    def generate(payment, request, options = {})

      #
      # 技术支持给的成功的示例
      # https://www.baifubao.com/api/0/pay/0/wapdirect?service_code=1&sp_no=9000100005&order_create_time=20150130090229&order_no=20150130090229751007&goods_name=345&goods_desc=&goods_url=&unit_amount=&unit_count=&transport_amount=&total_amount=1&currency=1&buyer_sp_username=&return_url=http%3A%2F%2Fwww.yoursite.com%2Freturn_url&page_url=http%3A%2F%2Fwww.yoursite.com%2Fpage_url&pay_type=2&bank_no=&expire_time=20150201090229&input_charset=1&version=2&sign_method=1&extra=&sign=2f346245481dce485b5fca769184b1e2
      # 顺序可变，空值不可忽略
      # 空值参与签名
      #

      product_name_string = payment.order.line_items.first.name rescue nil
      product_name_string = "- #{product_name_string}等" if product_name_string != nil

      # 银行编号列表
      params = {
          service_code: 1, # 服务编号
          sp_no: self.preferred_sp_no, # 百付宝门店号
          order_create_time: payment.order.placed_at.strftime('%Y%m%d%H%M%S'), # 创建订单的时间
          order_no: payment.order.number, # 订单号
          goods_name: "订单：#{payment.order.number}#{product_name_string}", # 商品的名称
          # goods_desc: '', # (optional) 商品描述
          # goods_url: '', # (optional) 商品 URL
          # unit_amount: '', # (optional) 单价
          # unit_count: '', # (optional) 数量
          # transport_amount: '', # (optional) 运费
          total_amount: yuan_to_cent(payment.amount), # 总金额，以分为单位
          currency: 1, # 币种
          # buyer_sp_username: '', # (optional) 用户在商家网站的名字
          return_url: Ddt::Payment::notify_url(payment, request), # 百度主动通知门店支付结果的 URL
          # page_url: '', # 用户点击该 URL 可以返回到门店网站：该URL也可以起到通知支付结果的作用
          pay_type: 2, # 默认支付方式， 1 余额， 2 网银， 3 银行网关支付
          # bank_no: '', # (optional) 银行编号
          expire_time: 1.days.since(payment.order.placed_at).strftime('%Y%m%d%H%M%S'), # 过期时间
          sp_uno: payment.order.user.id, # 用户在门店端的用户id或者用户名(必须在门店端唯一，用来形成快捷支付合约)
          input_charset: 1, # 请求参数的字符编码，只能是 GBK
          version: 2, # 接口的版本号,
          sign_method: 1, # 摘要算法 1 MD5 或 2 SHA-1
          # extra: '', # (optional) 门店自定义数据
      }

      params.merge! (options.select { |k, v| params.keys.include? k })
      params[:page_url] = options[:callback_url] if options[:callback_url]
      params.each {|k,v| params[k] = v.to_s.encode('GBK')}
      params[:sign] = sign(params);

      request_url = 'https://www.baifubao.com/api/0/pay/0/wapdirect'
      url = "#{request_url}?#{params.map { |k, v| "#{k}=#{url_encode(v.to_s)}" }.join('&')}"
      return {
          partner_id: params[:sp_no],
          out_trade_no: params[:order_no],
          method: 'baidupay',
          data_type: 'url',
          data: url,
          qr_code_url: nil
      }
    end

    def notify(payment, request)
      # I, [2015-01-30T21:07:52.206699 #27488]
      # INFO -- : [notify] {
      # :payment_id=>"287",
      # :params=>#<Hashie::Mash
      # bank_no=""
      # bfb_order_create_time="20150130184211"
      # bfb_order_no="2015013030000000091110311494416"
      # buyer_sp_username=""
      # currency="1"
      # extra=""
      # fee_amount="0"
      # input_charset="1"
      # order_no="1201501300002"
      # pay_result="1"
      # pay_time="20150130184211"
      # pay_type="2"
      # payment_id="287"
      # route_info=version=v1,
      # method=GET,
      # path=/:version/payments/:payment_id/notify(.:format)
      # sign="cc07895ceda54c67b8a0ca3d15f73d46"
      # sign_method="1"
      # sp_no="3000000009"
      # total_amount="1"
      # transport_amount="0"
      # unit_amount="1"
      # unit_count="1"
      # version="2">}

      #
      # 响应数据：
      # 接收到百度钱包的后台通知后，门店须返回特定的HTML页面。该页面应该满足以下要求：
      # HTML头部须包括<meta name="VIP_BFB_PAYMENT" content="BAIFUBAO">
      # 百度钱包只有检测到该字符串，才会认为门店已经成功接收到通知、已经验证过并且认可通知的内容。
      #
      params = request.params.clone
      [:route_info, :payment_id, :request_from].each do |unsign_key|
        params.delete(unsign_key)
      end
      raise 'verify sign fail' unless verify(params)
      raise 'pay not sucess' unless params[:pay_result] == '1'
      raise 'out_trade_no not_match' unless params[:order_no] == payment.out_trade_no
      {
          :verify => true,
          :content_type => 'text/html',
          :content => '<html><head><meta name="VIP_BFB_PAYMENT" content="BAIFUBAO"><title>bfb notify susscess</title></head><body>success</body></html>'
      }
    end

    private
    def sign(params)
      string1 = params.select.sort.map { |k, v| "#{k}=#{v.to_s}" }.join('&')
      string2 = "#{string1}&key=#{self.preferred_key}"
      puts string2
      Digest::MD5.hexdigest(string2)
    end

    def verify(params)
      verify_params = params.clone
      sign = verify_params[:sign]
      verify_params.except!(:sign)
      return sign(verify_params) == sign
    end
  end
end