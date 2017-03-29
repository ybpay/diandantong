json.array! @products do |product|
  json.(product, :id, :sku, :name, :price, :unit_name)
  json.categories product.categories.map(&:name_with_parent)
  json.variants product.variants do |variant|
    json.(variant, :id, :sku, :price, :name_with_options_text)
    json.options_text variant.cache_options_text
    json.option_value_ids variant.option_value_ids
  end
  json.option_types product.option_types do |option_type|
    json.(option_type, :id, :name)
    json.option_values option_type.option_values do |option_value|
      json.(option_value, :id, :name)
    end
  end
end