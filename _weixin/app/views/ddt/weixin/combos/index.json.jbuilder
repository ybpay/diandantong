json.cache! @combos, expires_in: 1.day do
  json.array! @combos do |combo|
    json.extract! combo, :id, :name, :description
    json.combo_items combo.combo_items do |combo_item|
      json.extract! combo_item, :id, :name, :select_count, :is_necessary, :price_strategy, :price, :vip_price, :original_price
      json.variants combo_item.variants do |variant|
        json.extract! variant, :id, :price, :vip_price, :sku, :stock_quantity, :sale_quantity, :is_master, :unit_name
        json.name         variant.cache_name
        json.options_text variant.cache_options_text
        json.image        variant.cache_image_url
        json.tag_ids variant.tag_ids
      end
    end
  end
end
