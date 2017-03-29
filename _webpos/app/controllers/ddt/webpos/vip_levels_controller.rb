module Ddt
  module Webpos
    class VipLevelsController < Ddt::Webpos::BaseController

      def index
        @vip_levels = @current_shop.vip_levels
        fresh_when(@vip_levels)
      end

    end
  end
end