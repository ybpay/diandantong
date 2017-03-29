json.partial! partial: '/ddt/weixin/order/base_order', locals: { order: @order }
json.extract! @order, :last_hasten_at_time, :last_call_waiter_at_time, :food_number

json.order_items do
  @order.adjustments.active.each do |adjustment|
    json.child! {
      json.name  adjustment.label
      json.value adjustment.amount_in_currency
    }
  end
  @order.form_contents.each do |form_content|
    json.child! {
      json.name  form_content.label
      json.value form_content.content
    }
  end
  json.child! {
    json.name '支付方式'
    json.value @order.pay_method_name
  }
  json.child! {
    json.name '支付状态'
    json.value @order.pay_item_state_name
  }
  if @order.payments.completed.count > 0
    json.child! {
      json.name '已支付'
      json.value @order.paid_amount_in_currency
    }
  end
  if @order.current_payment.present?
    json.child! {
      json.name '待支付'
      json.value @order.current_payment.amount_in_currency
    }
  end
  json.child! {
    json.name '备注'
    json.value @order.note.present? ? @order.note : '无'
  }
end
