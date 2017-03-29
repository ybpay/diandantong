module Ddt
  module Error
    class NoFeatureError < StandardError
      attr_accessor :key
      def initialize(key)
        @key = key
        super("未开通 #{Ddt::FeatureModules.module_name(key)} 模块，暂时无法使用此功能")
      end
    end
  end
end
