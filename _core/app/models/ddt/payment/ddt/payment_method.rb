#encoding: utf-8
#
# 用户在此配置可用来支付的方法
#

module Ddt
  class PaymentMethod < Base
    belongs_to :shop, class_name: 'Ddt::Shop', touch: true
    before_validation :initialize_preferences
    has_many :payments, class_name: 'Ddt::Payment'
    scope :active, ->{ where(active: true)}

    def generate(payment, request, options = {})
      {
          method: 'none', # 支付接口流程
          sub_method: nil, # 用以识别具体的支付方式
          version: 0, # 支付接口版本
          out_trade_no: 0, # 订单标识
          partner_id: 0, # 门店标识
          data_type: 'message', # 数据类型
          data: 'empty', # 数据
          qr_code_url: nil, # 二维码 URL
      }
    end

    def notify(payment, request)
      {
        verify: false,  # 校验成功或失败
        content_type: 'text/plain', # 输出格式
        content: 'fail' # 指导最终输出内容
      }
    end

    def query(payment)
      return false
    end

    #
    # 关闭交易
    # {
    #   success: T/F 是否关闭成功
    #   message: 关闭交易返回的消息
    # }
    #
    def close(payment)
      return true
    end

    def self.method_type_collection
      [
        ["支付宝", "Ddt::AlipayMethod"],
        ["百度钱包", "Ddt::BaidupayMethod"],
        ["微信支付", "Ddt::WechatpayMethod"]
      ]
    end

    protected
    def yuan_to_cent(yuan)
      (yuan * 100).to_i
    end

    def url_encode(str)
      CGI::escape(str)
    end

    private
    def initialize_preferences
      self.methods.grep(/preferred_.+=/).each do |it|
        reader = it[0...-1]
        send(it, "") if send(reader).nil?
      end
    end
  end
end
