json.partial! partial: 'base'
json.bill @list.content
json.items @list.items do |payment|
  json.order_number @list.order_numbers[payment.order_id] rescue nil
  json.amount payment.amount
  json.payment_method_name payment.payment_method.name
  json.state_name payment.workflow_state_name
  json.state payment.state
  json.out_trade_no payment.out_trade_no
  json.created_at payment.created_at.strftime("%F %H:%M")
  if payment.deleted_at
    json.deleted_at payment.deleted_at.strftime("%F %H:%M")
  else
    json.deleted_at nil
  end
end
