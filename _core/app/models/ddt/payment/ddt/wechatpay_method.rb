#encoding: utf-8
module Ddt
  class WechatpayMethod < PaymentMethod

    def name
      '微信支付'
    end

    protected
    #
    # 生成交易号
    #
    def generate_out_trade_no(payment)
      if Rails.env.production?
        "#{payment.id}_#{Time.now.strftime("%Y%m%d%H%M%S%s")}"
      else
        "tradeIdDev_#{Time.now.to_i.to_s}"
      end
    end

    #
    # 适用于 grape 和 controller 的 request 计算 remote_ip
    #
    def remote_ip(request)
      ip = request.headers['X-Forwarded-For'] unless ip.present?
      ip = request.headers['X-Real-Ip'] unless ip.present?
      ip = request.env['REMOTE_ADDR'] unless ip.present?
      ip.split(',')[0].strip if ip
    end
  end
end
