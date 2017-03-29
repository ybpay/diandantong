module Ddt
  module Webpos
    class TableZonesController < Webpos::BaseController

      def index
        @table_zones = @current_branch.table_zones.includes(:tables)
      end

      def with_reservation_time_points
        @table_zones = @current_branch.table_zones.includes(:reservation_time_points)
      end
    end
  end
end
