json.array! @promotions do |promotion|
  json.extract! promotion, :id, :name, :keywords, :starts_at, :expires_at
  json.image promotion.image.medium.url
end