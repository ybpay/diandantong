module Ddt
  module Webpos
    class DeliveryDatesController < Webpos::BaseController
      def index
        @delivery_dates = @current_branch.delivery_dates
        @branch_delivery_times = @current_branch.delivery_times
      end
    end
  end
end