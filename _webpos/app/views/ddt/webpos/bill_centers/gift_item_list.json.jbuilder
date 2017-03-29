render 'base'
json.bill @list.content
json.items @list.items do |item|
  json.order_number item.order_number
  json.table_name   item.table_name_with_zone
  json.name         item.itemable_name
  json.quantity     item.quantity
  json.price        item.original_price
  json.reason       item.gift_reason
  json.created_at   item.created_at
end
json.total_quantity @list.items.map(&:quantity).sum
json.total_amount @list.items.map{|i| i.original_price * i.quantity}.sum