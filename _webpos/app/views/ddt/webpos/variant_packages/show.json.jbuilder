json.extract! @variant_package, :id, :price, :itemable_id, :itemable_type, :itemable_name, :variant_id, :weight, :product_id
json.name @variant_package.itemable_name
json.is_by_weight true
