module Ddt
  module Webpos
    class DeliveryMansController < Webpos::BaseController
      def index
        @delivery_mans = @current_branch.deliverymans
        fresh_when(@delivery_mans)
      end
    end
  end
end
