class Ddt::NoWechatpayOpenIdException < StandardError;
  attr_accessor :wechatpay_method_v336
  attr_accessor :message

  def initialize(method = nil)
    @wechatpay_method_v336 = method
  end
end
