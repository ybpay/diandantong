json.partial! partial: 'base'
json.bill @list.content
json.total_amount @list.total_amount
json.total_quantity @list.total_quantity
json.items @list.group_items do |item|
  json.(item, :name, :unit_name, :total_quantity, :total_amount, :total_weight)
  json.variants item[:variants] do |variant|
    json.(variant, :name, :weight, :quantity, :amount, :percent)
  end
end