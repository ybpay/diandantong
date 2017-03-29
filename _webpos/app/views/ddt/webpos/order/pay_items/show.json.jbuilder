json.(@pay_item, :id, :name, :name_sym, :state, :state_name, :amount, :paid_amount, :change)
json.order_pay_item_state @pay_item.order.pay_item_state
json.online @pay_item.online?
json.pay_platform @pay_item.pay_platform?
if @bill.present?
  json.bill @bill
end
