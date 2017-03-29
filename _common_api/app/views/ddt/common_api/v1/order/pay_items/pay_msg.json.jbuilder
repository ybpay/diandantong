
json.extract! @order, :id, :pay_method, :pay_item_state, :multi_pay_item
json.pay_items @order.pay_items do |pay_item|
  json.(pay_item, :id, :order_id, :amount, :name, :name_sym, :state, :state_name, :paid_amount, :change)
  json.online pay_item.online?
  json.pay_platform pay_item.pay_platform?
end
