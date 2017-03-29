module Ddt
  module Webpos
    class TimeIntervalsController < Webpos::BaseController

      def index
        @time_intervals = @current_branch.shop.time_intervals
      end

    end
  end
end
