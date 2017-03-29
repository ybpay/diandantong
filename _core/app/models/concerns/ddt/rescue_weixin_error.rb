module Ddt
  module RescueWeixinError
    extend ActiveSupport::Concern

    included do
      rescue_from Ddt::WeixinApi::WeixinApiError, with: :weixin_error
    end

    module ClassMethods
      def weixin_crash_in(*actions, options)
        redirect_to_action = options[:redirect_to_action]
        actions.each do |action|
          define_method "crash_from_#{action}" do
            self.redirect_to action: redirect_to_action.to_sym
          end
        end
      end
    end

    private
      def weixin_error(e)
        flash[:error] = e.message
        self.send("crash_from_#{action_name}")
      end
  end
end
