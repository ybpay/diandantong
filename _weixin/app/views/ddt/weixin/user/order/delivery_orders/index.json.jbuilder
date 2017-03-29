json.array! @orders do |order|
  json.partial! partial: '/ddt/weixin/user/order/base_order', locals: { order: order}
  json.deliveryman_id   order.shipment.delivery_man_id
  json.delivery_name    order.delivery_name
  json.delivery_phone   order.delivery_phone
  json.delivery_address order.delivery_address
  json.delivery_date    order.delivery_date
  json.delivery_time_display order.delivery_time_display
  json.pay_item_state_name    order.pay_item_state_name
  json.distance        order.distance.round(2)
  json.pay_method_name_syms order.pay_items.map(&:pay_method_name_sym)
end
