json.partial! partial: '/ddt/weixin/order/base_order', locals: { order: @order }
json.extract! @order, :last_hasten_at_time, :longitude, :latitude, :shipment_total
json.order_items do
  @order.adjustments.active.each do |adjustment|
    json.child! {
      json.name  adjustment.label
      json.value adjustment.amount_in_currency
    }
  end
  json.child! {
    json.name '配送员'
    json.value @order.delivery_man_name
  }
  json.child! {
    json.name '联系方式'
    json.value @order.delivery_man.try(:phone)
  }
  json.child! {
    json.name '配送区域'
    json.value @order.delivery_zone_name
  }
  json.child! {
    json.name '配送时间'
    json.value @order.delivery_time_display
  }
  json.child! {
    json.name '配送日期'
    json.value @order.delivery_date_str
  }
  json.child! {
    json.name '配送状态'
    json.value @order.shipment_state_name
  }
  json.child! {
    json.name '收货人'
    json.value @order.delivery_name
  }
  json.child! {
    json.name '电话'
    json.value @order.delivery_phone
  }
  json.child! {
    json.name '地址'
    json.value @order.delivery_address
  }
  json.child! {
    json.name '距离门店距离'
    json.value "#{@order.distance.round(2)}公里"
  }
  json.child! {
    json.name '备注'
    json.value @order.note.present? ? @order.note : '无'
  }
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
end
location = @order.shipment.deliveryman_location
if location.present?
  json.deliveryman_location do
    json.partial! partial: '/ddt/weixin/order/delivery_orders/location', locals: { location: location}
  end
end