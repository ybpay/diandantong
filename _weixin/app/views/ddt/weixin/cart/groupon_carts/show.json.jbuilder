json.extract! @cart, :id, :type, :item_total, :total, :item_count
json.line_items @cart.line_items do |line_item|
  json.extract! line_item, :id, :itemable_type, :itemable_id, :price, :original_price, :quantity, :amount, :total, :name, :unit_name, :gift
  json.itemable do
    json.image line_item.itemable.avatar_url
  end
end

