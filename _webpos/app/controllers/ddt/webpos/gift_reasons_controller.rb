module Ddt
  module Webpos
    class GiftReasonsController < Ddt::Webpos::BaseController
      def index
        @gift_reasons = @current_shop.gift_reasons
        fresh_when(@gift_reasons)
      end
    end
  end
end