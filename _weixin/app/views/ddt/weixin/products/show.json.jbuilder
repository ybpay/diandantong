json.extract! @product, :id, :name, :branch_id, :description, :unit_name, :min_quantity_for_order, :show_note_in_weixin
json.categories @product.categories.map(&:name)
json.tags @product.tags do |tag|
    json.extract! tag, :id, :name
  end
json.images @product.images do |image|
  json.partial! partial: '/ddt/weixin/variants/image', locals: { image: image }
end
json.variants(@product.variants_including_master) do |variant|
  json.extract! variant, :id, :options_text, :vip_price, :sku, :stock_quantity, :sale_quantity, :is_master, :min_quantity_for_order, :show_note_in_weixin
  json.original_price variant.price
  json.price @current_user.get_price_of_itemable(variant)
  json.itemable_type 'Ddt::Variant'
  json.itemable_id variant.id
  json.name variant.name_with_options_text
  json.category_ids @product.category_ids
end