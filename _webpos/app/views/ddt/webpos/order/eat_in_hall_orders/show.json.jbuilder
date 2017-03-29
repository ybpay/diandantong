json.cache! @order.cache_key, expires_in: 2.hours do
  json.partial! partial: '/ddt/webpos/order/base_show', locals: { order: @order }
  json.table_id @order.table_id
  json.table_name @order.table_name_with_zone
  json.ban_selfpay @order.ban_selfpay
  json.guest_num @order.guest_num
end