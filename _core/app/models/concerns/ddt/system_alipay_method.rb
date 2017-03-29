# encoding: utf-8
module Ddt
  module SystemAlipayMethod
    extend ActiveSupport::Concern
    included do

    end

    module ClassMethods
      def use_system_alipay
        Ddt::AlipayMethod.set_current(system_alipay_method)
      end

      def system_alipay_method
        preferences = Hash[ [:pid, :pkey, :email].map { |key| [key, SystemAlipayConfig.send(key)] } ]
        method = Ddt::AlipayMethod.new(preferences: preferences)
      end
    end
  end
end
