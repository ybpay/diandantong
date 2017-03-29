json.cache! @gift_reasons, expires_in: 1.day do
  json.array! @gift_reasons do |gift_reason|
    json.extract! gift_reason, :id, :name
  end
end
