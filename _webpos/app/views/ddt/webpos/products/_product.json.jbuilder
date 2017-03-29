json.cache! product, expires_in: 1.day do
  json.extract! product, :id, :price, :min_quantity_for_order, :on_shelf , :estimate_clear, :unit_name, :start_time, :end_time, :support_delivery, :support_reservation, :support_eat_in_hall, :updated_at
  json.cache_version product.updated_at.to_i * 1000
  json.name "#{product.name}"
  json.name_abbr "#{product.name_abbr}"
  json.sku "#{product.sku}"
  json.category_ids product.category_ids
  if product.variants.present?
    variants = product.variants
  else
    variants = [product.master]
  end
  json.variants variants.each do |variant|
    json.extract! variant, :id, :price, :is_master, :sku, :itemable_id, :itemable_type, :product_id, :stock_quantity, :min_quantity_for_order , :is_by_weight, :default_weight,:estimate_clear,:estimate_clear_reciprocal
    json.original_price variant.price
    json.name variant.cache_name
    json.options_text variant.cache_options_text
  end
end
