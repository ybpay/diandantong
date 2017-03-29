module Ddt
  module Webpos
    class DeliveryZonesController < Webpos::BaseController
      def index
        @delivery_zones = @current_branch.delivery_zones
        fresh_when(@delivery_zones)
      end
    end
  end
end