json.cache! Digest::MD5.hexdigest(@products.map(&:cache_key).join), expires_in: 1.day do
  json.array! @products do |product|
    json.cache! [product], expires_in: 1.day do
      product_category_ids = product.category_ids
      json.extract! product, :id, :name, :branch_id, :unit_name, :min_quantity_for_order, :show_note_in_weixin, :estimate_clear
      json.category_ids product_category_ids
      json.tag_ids product.tag_ids.uniq
      json.item_notes product.item_notes do |item_note|
        json.extract! item_note, :id, :name
      end
      json.variants(product.variants_including_master) do |variant|
        json.extract! variant, :id, :vip_price, :sku, :is_master, :min_quantity_for_order, :show_note_in_weixin, :estimate_clear
        json.original_price variant.price
        json.itemable_type 'Ddt::Variant'
        json.itemable_id variant.id
        json.name         variant.cache_name
        json.options_text variant.cache_options_text
        json.image        variant.cache_image_url
        json.category_ids product_category_ids
      end
    end
    json.total_sale_quantity product.total_sale_quantity
    json.variant_infos do
      variants = product.variants_including_master.to_a
      json.prices          variants.map{|variant| @current_user.get_price_of_itemable(variant)}
      json.stock_quantitys variants.map(&:stock_quantity)
      json.sale_quantitys  variants.map(&:sale_quantity)
    end
  end
end
