module Ddt
  module Webpos
    class DiscountPlansController < Webpos::BaseController

      def index
        @discount_plans = @current_branch.discount_plans.active
        fresh_when(@discount_plans)
      end
    end
  end
end
