json.partial! partial: '/ddt/weixin/order/base_order', locals: { order: @order }
json.table_zone do
  json.extract! @order.table_zone, :name, :min_reservation_price
end
json.extract! @order, :prepayment_type, :reservation_date_str, :reservation_time_point_str, :name, :phone, :gender_name, :amount_for_pay
json.exchange_code_id @order.exchange_code.try(:id)
json.order_items do
  json.child! {
    json.name "预订人信息"
    json.value @order.reservation_info.reservation_customer_info
  }

  json.child! {
    json.name "预订时间"
    json.value @order.reservation_info.reservation_time_info
  }

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
  if @order.is_prepay_for_order?
    json.child! {
      json.name '预付款比例'
      json.value "#{@order.table_zone.reservation_price_percent}%"
    }
  end
  json.child! {
    json.name '备注'
    json.value @order.note.present? ? @order.note : '无'
  }
end