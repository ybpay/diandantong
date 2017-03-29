json.partial! partial: 'base'
json.group_items do
  @list.group_items.each do |group_name, items|
    json.set! group_name do
      json.array! items do |item|
        json.(item, :name, :quantity, :adjustment_total, :not_actual_amount, :amount, :percent)
      end
    end
  end
end
json.bill @list.content
json.total_amount @list.total_amount
json.total_quantity @list.total_quantity
json.total_adjustment @list.total_adjustment
json.total_not_actual_amount @list.total_not_actual_amount
json.moling_amount @list.moling_amount
