json.partial! partial: 'base'
json.bill @list.content
json.items @list.items do |item|
  json.name item.name
  json.shift_items item.items, :pay_method_name, :pay_method_code, :amount, :cash_amount, :extra_amount
  json.total_amount item.total_amount
  json.total_actual_amount item.total_actual_amount
  json.label_items item.label_items
end