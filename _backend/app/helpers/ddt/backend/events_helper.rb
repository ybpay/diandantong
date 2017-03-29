module Ddt
  module Backend
    module EventsHelper
      def events_index_path_with_flag(flag)
        "#{backend_shop_events_path(@current_shop)}?flag=#{flag}"
      end
      def new_event_path_with_type(type)
        "#{new_backend_shop_event_path(@current_shop)}?event_type=#{type}"
      end
    end
  end
end