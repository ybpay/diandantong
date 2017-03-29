#encoding:utf-8

#
# gem 中的 Alipay 只支持全局帐户，因此重定义获取帐户信息的方法。
#
module Alipay
  class << self

    def current
      RequestStore.store[:current_alipay_method]
    end

    def set_current(method)
      RequestStore.store[:current_alipay_method] = method
      if block_given?
        begin
          yield
        ensure
          RequestStore.store[:current_alipay_method] = nil
        end
      end
    end

    def pid
      Alipay.current.pid
      # Ddt::AlipayMethod.current.get_pid
    end
    def key
      Alipay.current.key
      # Ddt::AlipayMethod.current.get_pkey
    end
    def seller_email
      Alipay.current.email
      # Ddt::AlipayMethod.current.get_email
    end
  end
end
