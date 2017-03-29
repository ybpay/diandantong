module Ddt
  module MessageHandlerMethod
    class ThirdParty < ::Ddt::MessageHandlerMethod::Base
      def handle_text
        wechat_account.keywords_third_party_interfaces.opened.detect do |interface|
          interface.keywords_match? message.content
        end
      end
    end
  end
end