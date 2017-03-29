json.extract! @product, :id, :name, :price, :sku, :name_abbr, :min_quantity_for_order, :on_shelf , :estimate_clear, :unit_name, :show_note_in_weixin, :description
if @product.variants.present?
  variants = @product.variants
else
  variants = [@product.master]
end
json.variants variants.each do |variant|
  json.extract! variant, :id, :price, :is_master, :sku, :product_id, :itemable_id, :itemable_type, :stock_quantity, :min_quantity_for_order , :by_weight, :default_weight,:estimate_clear,:estimate_clear_reciprocal
  json.original_price variant.price
  json.image_url variant.cache_image_url
  json.name variant.cache_name
  json.options_text variant.cache_options_text
end