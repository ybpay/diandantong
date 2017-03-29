json.partial! partial: 'base'
json.bill @list.content
json.items @list.items do |item|
  json.extract! item, :order_number, :table_name_with_zone, :created_at, :itemable_name, :quantity, :price, :subtract_reason, :amount, :operator_name
end
json.total_amount @list.total_amount
json.total_quantity @list.total_quantity