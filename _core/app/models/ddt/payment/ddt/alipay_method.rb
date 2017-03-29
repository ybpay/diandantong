# encoding: utf-8
module Ddt
  class AlipayMethod < PaymentMethod
    include Ddt::Core::Engine.routes.url_helpers
    include Ddt::SystemAlipayMethod

    DEFAULT_AGENT_ID = '11864042a1'

    ALIPAY_RSA_PUBLIC_KEY = <<-EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDI6d306Q8fIfCOaTXyiUeJHkr
IvYISRcc73s3vF1ZT7XN8RNPwJxo8pWaJMmvyTn9N4HQ632qJBVHf8sxHi/fEsra
prwCtzvzQETrNRwVxLO5jVmRGi60j8Ue1efIlzPXV9je9mkjzOmdssymZkh2QhUr
CmZYI/FCEa3/cNMW0QIDAQAB
-----END PUBLIC KEY-----
    EOF

    CONTRACT_COLLECTIONS = [
        ['手机网站支付（开放平台）', 'open_wap', '新申请的手机网站支付勾选此项'],
        ['手机网站支付', 'wap', '用在微信端由客户发起支付'],
        ['当面付V4', 'pay_on_face_v4', '用在收银端和APP,包括二维码收单和扫码收单'],
        ['即时到账', 'create_direct_pay_by_user', '网页支付,备选方案,对微信用户的体验极差'],
        ['二维码收单V2', 'qr_code_v2', '遗留接口,用于二维码收单,请新客户申请当面付']
    ]

    # 代收相关
    preference :collection, :boolean, :default => false
    preference :withdraw_account_id, :string
    preference :withdraw_account_name, :string


    def self.custom_attribute(attr_sym)
      self.class_eval do
        # 定义偏好属性
        preference attr_sym, :string
        # 持久化前去掉前后的空白
        before_validation do
          self.send("preferred_#{attr_sym}=", self.send("preferred_#{attr_sym}").strip) if self.send("preferred_#{attr_sym}")
        end
        # 支付
        define_method "get_#{attr_sym}" do
          preferred_collection ? Ddt::SystemAlipayConfig.send(attr_sym) : self.send("preferred_#{attr_sym}")
        end
      end
    end

    # 非代收相关
    custom_attribute :pid
    custom_attribute :pkey
    custom_attribute :email
    custom_attribute :app_id
    custom_attribute :rsa_pri_key

    preference :contract, :string, :default => ''

    validates :preferred_withdraw_account_id, :preferred_withdraw_account_name, presence: true, if: :validate_collection_infos?
    validates :preferred_pid, :preferred_pkey, :preferred_email, presence: true, if: :validate_alipay_infos?
    before_validation do
      self.preferred_withdraw_account_id = self.preferred_withdraw_account_id.gsub(' ', '') if self.preferred_withdraw_account_id
      self.preferred_withdraw_account_name = self.preferred_withdraw_account_name.gsub(' ', '') if self.preferred_withdraw_account_name
    end

    def agent_id
      agent_id = shop.agent.try(:alipay_agent_id)
      agent_id.present? ? agent_id : DEFAULT_AGENT_ID
    end

    def include_contract?(contract)
      if preferred_collection then
        Ddt::SystemAlipayConfig.contract.split('|').include? contract
      else
        self.preferred_contract.split('|').include? contract
      end
    end

    def create_payment_method(payment, request, options = {})

      if payment.preferred_sub_method.present?
        klass = [
            Ddt::Alipay::CreateDirectPayByUser,
            Ddt::Alipay::QrCodeLegacy,
            Ddt::Alipay::TradePay,
            Ddt::Alipay::TradePrecreate,
            Ddt::Alipay::Uniorder,
            Ddt::Alipay::Unipreorder,
            Ddt::Alipay::OpenWap,
            Ddt::Alipay::Wap,
            Ddt::Alipay::Web
        ].find do |klass|
          klass.sub_method_name == payment.preferred_sub_method
        end
      else
        request_from = options[:request_from] || 'wap'
        case request_from
          when 'seller_scan'
            if include_contract? 'pay_on_face_v4'
              klass = Ddt::Alipay::TradePay
            else
              klass = Ddt::Alipay::Uniorder
            end
          when 'buyer_scan'
            if include_contract? 'pay_on_face_v4'
              klass = Ddt::Alipay::TradePrecreate
            elsif include_contract? 'qr_code_v2'
              klass = Ddt::Alipay::Unipreorder
            else
              klass = Ddt::Alipay::QrCodeLegacy
            end
          when 'web'
            if include_contract? 'create_direct_pay_by_user'
              klass = Ddt::Alipay::CreateDirectPayByUser
            else
              klass = Ddt::Alipay::Web
            end
          else
            if include_contract? 'open_wap'
              klass = Ddt::Alipay::OpenWap
            elsif include_contract? 'wap'
              klass = Ddt::Alipay::Wap
            elsif include_contract? 'create_direct_pay_by_user'
              klass = Ddt::Alipay::CreateDirectPayByUser
            else
              # default, try wap pay
              klass = Ddt::Alipay::Wap
            end
        end
      end

      payment_method = klass.new(payment, request, options)
      payment_method.pid = get_pid
      payment_method.key = get_pkey
      payment_method.email = get_email
      payment_method.app_id = get_app_id
      payment_method.rsa_pri_key = get_rsa_pri_key
      payment_method.agent_id = agent_id
      payment_method.request_from = request_from
      payment_method
    end


    #
    # 生成支付接口
    # options:
    #   out_trade_no 交易号，默认为当前时间
    #   subject 商品名，默认为“支付+交易号"
    #   return_url 默认为支付完成页
    #   request_from web/wap/app, 默认为 wap
    #   generate_qr_code 生成二维码，默认为 false
    #
    def generate(payment, request, options = {})
      payment_method = create_payment_method(payment, request, options)
      RequestStore[:payment_method_object] = payment_method
      result = {}
      ::Alipay.set_current(payment_method) do
        # uniorder 可能调用后立即返回,这里 payment 状态还没改回来,需要特殊处理
        if payment_method.request_from != 'seller_scan'
          result.merge! payment_method.invoke
        else
          result.merge!({
              sub_method: payment_method.sub_method_name,
              partner_id: payment_method.pid,
              out_trade_no: payment_method.out_trade_no
          })
        end
      end
      return result
    end

    #
    # 因为支付宝的即时支付处理，先把状态变更过来，再通知支付宝进行支付操作
    #
    def after_pending(from, to, event, request, options)
      result = nil
      if options[:request_from] == 'seller_scan'
        result = {}
        payment_method = RequestStore[:payment_method_object]
        ::Alipay.set_current(payment_method) do
          result.merge! payment_method.invoke
        end
      end
      result
    end




    #
    # 处理支付通知
    #
    #
    #
    #
    def notify(payment, request)
      m = create_payment_method(payment, request, {request_from: request.params[:request_from]})
      result = false
      ::Alipay.set_current(m) do
        result = m.notify
      end

      #
      # 对支付宝在线、移动支付宝通知，支付宝只响应 success。
      # 如果未收到 success ，服务器会重发。
      #
      # 对扫码支付通知，文档规定成功/失败分别返回 success/fail
      #
      {
          :verify => result,
          :content_type => 'text/plain',
          :content => result ? 'success' : 'fail'
      }
    end

    def name
      '支付宝'
    end

    def query(payment)
      create_payment_method(payment, nil, {}).query
    end

    def close(payment)
      create_payment_method(payment, nil, {}).close
    end

    def refund(payment, options = {})
      create_payment_method(payment, nil, options).refund
    end

    def validate_collection_infos?
      self.active? and self.preferred_collection == true
    end

    def validate_alipay_infos?
      self.active? and self.preferred_collection == false
    end

  end
end
