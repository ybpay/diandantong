# encoding: utf-8
module Ddt
  module SystemMaterial
    class Unmatch < ::Ddt::SystemMaterial::Base
      def build_message
        event = shop.events.by_event_type(:unmatch).first
        message.create_response_from_event(event)
      end
    end
  end
end
