json.cache! @order.cache_key, expires_in: 2.hours do
  json.partial! partial: '/ddt/common_api/v1/order/base_show', locals: { order: @order }
  json.table_name @order.table_name_with_zone
  json.guest_num @order.guest_num
  json.table_id @order.table_id
end
