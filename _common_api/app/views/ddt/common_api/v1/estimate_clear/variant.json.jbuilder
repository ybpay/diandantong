json.variant do
  json.(@variant, :id, :stock_quantity, :estimate_clear_reciprocal)
  json.name @variant.name_with_options_text
end
json.product do
  json.partial! partial: '/ddt/webpos/products/product', locals: { product: @variant.product }
end