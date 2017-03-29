json.array! @products do |product|
  json.cache! product, expires_in: 1.day do
    json.extract! product, :id, :name, :sku, :name_abbr, :min_quantity_for_order, :on_shelf , :estimate_clear, :unit_name, :show_note_in_weixin, :description, :start_time, :end_time, :support_delivery, :support_reservation, :support_eat_in_hall
    json.price product.price.to_f
    json.category_ids product.category_ids
    json.images product.images do |image|
      json.url        image.attachment.url
      json.small_url  image.attachment.small.url
      json.rect_normal_url image.attachment.rect_normal.url
      json.rect_large_url image.attachment.rect_large.url
    end
    if product.variants.present?
      variants = product.variants
    else
      variants = [product.master]
    end
    json.variants variants.each do |variant|
      json.extract! variant, :id, :is_master, :sku, :product_id, :itemable_id, :itemable_type, :stock_quantity, :min_quantity_for_order , :by_weight, :unit_name, :default_weight,:estimate_clear,:estimate_clear_reciprocal
      json.nfc_code variant.nfc_code
      json.price variant.price.to_f
      json.original_price variant.price.to_f
      json.name variant.cache_name
      json.options_text variant.cache_options_text
    end
    json.item_notes product.item_notes do |item_note|
      json.extract! item_note, :id, :name
    end
  end
end
