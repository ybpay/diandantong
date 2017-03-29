json.partial! partial: 'base';
json.bill @list.content
json.total_sale_quantity @list.total_sale_quantity
json.total_sale_amount   @list.total_sale_amount
json.items @list.group_items do |item|
  json.name item[:name]
  json.sale_quantity item[:sale_quantity]
  json.sale_amount item[:sale_amount]
  json.variants do
    item[:variants].each do |name, quantity|
      json.set! name, quantity
    end
  end
end
