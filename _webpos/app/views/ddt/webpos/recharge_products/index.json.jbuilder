json.cache! @recharge_products.cache_key, expires_in: 1.day do
  json.array! @recharge_products do |recharge_product|
    json.(recharge_product, :id, :name, :price, :recharge_amount, :position, :sales_count, :extra_credits, :first_recharge_available_amount, :itemable_type, :itemable_id, :original_price)
  end
end
