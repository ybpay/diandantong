json.extract! order, :id, :branch_id, :number, :total, :type, :item_count, :placed_at, :state, :pay_item_state, :shipment_state, :pay_item_total, :state_name, :pay_method, :pay_method_name, :tax_total, :is_commented, :base_user_id
json.total_for_show order.amount_for_pay
json.branch_name order.branch.try(:name)
json.line_items order.line_items.active do |line_item|
  json.extract! line_item, :id, :itemable_type, :itemable_id, :name, :quantity, :price, :original_price, :amount, :total, :unit_name, :gift, :note, :name_with_note, :is_append
  json.active_quantity line_item.active_quantity
  json.min_quantity_for_order (line_item.itemable.try(:min_quantity_for_order) || 1)
end
json.all_line_items order.line_items do |line_item|
  json.extract! line_item, :id, :name, :quantity, :active_quantity, :total, :unit_name, :price, :original_price, :note, :name_with_note, :is_append, :is_subtract,:itemable_id
end
if order.is_canceled?
  json.order_items do
    json.child! {
      json.name '取消原因'
      json.value order.cancel_reason
    }
  end
end
json.invoice do
  if order.invoice
    json.extract! order.invoice, :invoice_type, :title
  else
    nil
  end
end
