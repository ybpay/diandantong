module Ddt
  module Error
    class FeatureNotEnabled < StandardError
      attr_accessor :key
      def initialize(key, disable_reason)
        @key = key
        super("disable_reason||#{Ddt::FeatureModules.module_name(key)} 模块已被商家关闭服务，详情咨询商家")
      end
    end
  end
end
