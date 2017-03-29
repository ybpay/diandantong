json.partial! partial: '/ddt/weixin/order/base_order', locals: { order: @order }
json.order_items do
  @order.adjustments.active.each do |adjustment|
    json.child! {
      json.name  adjustment.label
      json.value adjustment.amount_in_currency
    }
  end
  json.child! {
    json.name '支付方式'
    json.value @order.pay_method_name
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