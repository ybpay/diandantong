json.partial! partial: 'base'
json.bill @list.content
json.items @list.items do |item|
  json.order_number  item.order_number
  json.order_type    item.order_type_name
  json.table_name    item.order_table_name_with_zone
  json.order_amount  item.order_total
  json.created_at    item.created_at.strftime("%F %T")
  json.operator_name item.operator_name
end