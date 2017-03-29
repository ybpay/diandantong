json.cache! @combos.cache_key, expires_in: 1.day do
  json.array! @combos do |combo|
    json.extract! combo, :id, :name, :description, :vip_price, :on_shelf, :start_time, :end_time, :support_delivery, :support_reservation, :support_eat_in_hall
    json.original_price combo.price
    json.combo_items combo.combo_items do |combo_item|
      json.extract! combo_item, :id, :name, :select_count, :is_necessary, :price, :vip_price
      json.variants combo_item.sorted_variants do |variant|
        json.extract! variant, :id, :price, :vip_price, :sku, :stock_quantity, :sale_quantity, :is_master
        json.name         variant.cache_name
        json.options_text variant.cache_options_text
        json.image        variant.cache_image_url
      end
    end
  end
end
