json.array! @active_line_items do |line_item|
  json.extract! line_item, :id, :price, :unit_name, :itemable_type, :name, :active_quantity, :gift, :note, :gift_reason
end
