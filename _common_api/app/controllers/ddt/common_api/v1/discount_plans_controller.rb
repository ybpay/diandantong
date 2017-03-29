module Ddt
  module CommonApi
    module V1
      class DiscountPlansController < V1::BaseController
        def index
          @discount_plans = @current_branch.discount_plans.active
          fresh_when(@discount_plans)
        end
      end
    end
  end
end
