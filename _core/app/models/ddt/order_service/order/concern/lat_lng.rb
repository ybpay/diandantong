module Ddt
  module OrderService
    module Order
      module Concern
        module LatLng
          extend ActiveSupport::Concern
          included do
            include Ddt::LatLng
            delegate :distance_to, to: :lat_lng_point
          end

          def distance
            self.distance_to(self.branch.lat_lng_point, units: :kms, fomula: :sphere) rescue nil
          end
        end
      end
    end
  end
end