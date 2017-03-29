json.extract! combo, :id, :name, :description, :vip_price, :on_shelf
json.original_price combo.price
json.images combo.images do |image|
  json.url        image.attachment.url
  json.small_url  image.attachment.small.url
  json.rect_normal_url image.attachment.rect_normal.url
  json.rect_large_url image.attachment.rect_large.url
end
json.combo_items combo.combo_items do |combo_item|
  json.extract! combo_item, :id, :name, :select_count, :is_necessary, :price, :vip_price
  json.variants combo_item.variants do |variant|
    json.extract! variant, :id, :price, :vip_price, :sku, :stock_quantity, :sale_quantity, :is_master, :unit_name
    json.name         variant.cache_name
    json.options_text variant.cache_options_text
    json.image        variant.cache_image_url
  end
end
