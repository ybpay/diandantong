json.array! @zones do |zone|
  json.extract! zone, :id, :name, :parent_zone_id
end
