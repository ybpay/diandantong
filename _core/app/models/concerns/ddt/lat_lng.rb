module Ddt
  module LatLng
    extend ActiveSupport::Concern
    def lat_lng
      [latitude, longitude]
    end

    def lat_lng=(lat_and_lng=[])
      latitude, longitude = lat_and_lng
    end

    def lat_lng_present?
      lat_lng.compact.size == 2
    end

    def lat_lng_point
      Geokit::LatLng.new(latitude, longitude)
    end
  end
end