json.(@shift, :id, :created_at,:total_amount,:total_actual_amount,:recharge_amount,:exchange_amount,:print_text,:recharge_print_text,:pre_cash_amount,:pending_orders_before,:pending_orders_after,:confirmed_orders_before,:confirmed_orders_after,:completed_orders_before,:completed_orders_after, :total_customter_count, :total_eat_in_hall_order_count, :per_capita_consumption, :per_eat_in_hall_order_consumption, :order_from_wechat_count, :order_from_webpos_count, :order_from_app_count, :order_from_unknow_count,  :subtract_item_count, :total_subtract_item_amount, :unpaid_amount, :discount_amount, :moling_amount)
json.total_discount_amount @shift.total_amount - @shift.total_actual_amount
json.shift_items @shift.shift_items do |item|
  json.(item, :pay_method_name, :pay_method_code, :amount, :cash_amount, :extra_amount, :count)
end
json.active_orders_count @current_branch.orders.active.count
