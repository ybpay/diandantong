json.cache! order.cache_key, expires_in: 2.hours do
  json.extract! order, :id, :type_str, :branch_id, :number, :total, :total_in_currency, :item_count, :placed_at, :state, :pay_item_total, :state_name, :tax_total, :pay_item_state, :pay_item_state_name, :related_order_id, :track_from, :waiter_id, :waiter_name, :ban_selfpay, :table_id
  json.line_items order.line_items.active.include_itemables(variant: :product, variant_package: { variant: :product }, combo_package: :combo) do |line_item|
    json.extract! line_item, :id, :itemable_type, :itemable_id, :name, :quantity, :price, :original_price, :amount, :total, :note, :gift, :is_change_price, :created_at, :is_append, :active_quantity, :enable_change_price, :is_from_move
  end
  json.adjustments order.adjustments.active do |adjustment|
    json.extract! adjustment, :id, :label, :amount, :amount_in_currency
  end
  json.has_discount_plan order.discount_plan_adjustment.present?

end
