json.cache! current_shop, expires_in: 1.day do
  json.extract! current_shop, :id, :name, :currency, :slug, :card_key, :use_shop_name_for_queue, :image_url, :shop_type
end