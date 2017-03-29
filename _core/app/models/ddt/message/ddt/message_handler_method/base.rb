module Ddt
  module MessageHandlerMethod
    class Base
      attr_reader :message
      delegate :shop, :wechat_account, to: :message
      def initialize(message)
        @message = message
      end

      [:text, :image, :link, :location,
       :subscribe, :subscribe_with_key, :unsubscribe, :scan, :report_location, :click, :view].each do |type|
        define_method "handle_#{type}" do
        end
      end
    end
  end
end
