json.array! @delivery_mans do |delivery_man|
  json.extract! delivery_man, :id, :name
end