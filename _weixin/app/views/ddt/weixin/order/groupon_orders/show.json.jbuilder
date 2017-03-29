json.partial! partial: '/ddt/weixin/order/base_order', locals: { order: @order }
if @order.state == "completed"
  coupons = @order.base_coupons
  json.exchange_codes @order.line_items.each do |line_item|
    json.line_item_id line_item.id
    line_item_coupons = coupons.select{|coupon| coupon.abstract_coupon_version_id == line_item.itemable_id}
    json.codes line_item_coupons.map {|coupon| {code: coupon.exchange_code.code, coupon_id: coupon.id, coupon_type_str: coupon.type_str}}

  end
end
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
