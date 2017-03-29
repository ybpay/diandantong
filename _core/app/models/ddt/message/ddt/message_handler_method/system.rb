# encoding: utf-8
module Ddt
  module MessageHandlerMethod
    class System < ::Ddt::MessageHandlerMethod::Base
      def handle_text
        handle_system_key(message.content)
      end

      def handle_image
        message.response("谢谢您的图片上传")
      end

      def handle_subscribe
        Ddt::SystemMaterial::Help.new(message).build_message
      end

      def handle_subscribe_with_key
        scene_id = message.event_key.split("_")[1]
        Ddt::SystemMaterial::Scene.new(message, scene_id).build_message
      end

      def handle_scan
        scene_id = message.event_key
        Ddt::SystemMaterial::Scene.new(message, scene_id).build_message
      end

      def handle_system_key(key)
        case key
        when '0'
          return Ddt::SystemMaterial::Help.new(message).build_message
        when '1'
          return Ddt::SystemMaterial::Shop.new(message).build_message
        when '2'
          return Ddt::SystemMaterial::Promotion.new(message).build_message
        when '3'
          return Ddt::SystemMaterial::Order.new(message).build_message
        when '4'
          return Ddt::SystemMaterial::VipUser.new(message).build_message
        when '9','CustomerServiceSystemMaterial'
          return Ddt::SystemMaterial::CustomerService.new(message).build_message
        when /^[\s]*@[\s]*$/
          Ddt::SystemMaterial::At.new(message).build_message
        else
          Ddt::SystemMaterial::Unmatch.new(message).build_message
        end
      end
    end
  end
end
