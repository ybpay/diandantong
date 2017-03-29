json.partial! partial: 'base'
json.bill @list.content
json.items @list.items do |item|
  json.(item,
        :order_number,
        :table_name,
        :created_at,
        :label,
        :amount,
        :operator_name,
        :authorizer_name)
end
json.total_discount_amount @list.total_discount_amount