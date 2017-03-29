json.array! @delivery_zones do |delivery_zone|
  json.extract! delivery_zone, :id, :zone_name
  json.cost delivery_zone.try(:cost) || 0
end