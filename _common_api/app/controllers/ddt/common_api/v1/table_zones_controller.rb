module Ddt
  module CommonApi
    module V1
      class TableZonesController < V1::BaseController

        def index
          @table_zones = @current_branch.table_zones
        end

        def with_tables
          @table_zones = @current_branch.table_zones.includes(:tables)
        end

        def with_reservation_time_points
          @table_zones = @current_branch.table_zones.includes(:reservation_time_points)
        end
      end
    end
  end
end
