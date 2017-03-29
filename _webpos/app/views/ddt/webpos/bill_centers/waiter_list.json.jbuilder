json.partial! partial: 'base'
json.bill @list.content
json.items @list.items do |item|
  json.waiter_name item.waiter_name
  json.order_count item.order_quantity
  json.order_amount item.order_sale_amount
  json.order_average item.average_sale_amount
end
json.total_orders_amount @list.total_orders_amount