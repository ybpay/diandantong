module Ddt
  module MessageHandlerMethod
    class Customer < ::Ddt::MessageHandlerMethod::Base
      def handle_text
        event = shop.events.where(event_key: message.content).first
        message.create_response_from_event(event)
      end

      def handle_subscribe
        event = shop.events.by_event_type(:subscribe).first
        message.create_response_from_event(event)
      end

      def handle_click
        event_key = message.event_key
        if event_key.start_with?(Ddt::Event::KEY_PREFIX)
          system_keyword = Ddt::Event.clear_prefix(event_key)
          Ddt::MessageHandlerMethod::System.new(message).handle_system_key(system_keyword)
        else
          material = shop.materials.find_by_id(event_key)
          message.create_response_from_material(material)
        end
      end

      def handle_view
        # 跳转的 url
        # message.event_key
      end
    end
  end
end