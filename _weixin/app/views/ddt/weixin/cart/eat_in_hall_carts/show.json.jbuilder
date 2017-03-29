json.partial! partial: '/ddt/weixin/cart/base_cart', locals: { cart: @cart }
json.extract! @cart, :table_id, :guest_num
json.ban_selfpay (@cart.table && @cart.table.ban_selfpay)
json.table do
  json.id             @cart.table_id
  json.name           @cart.table_name
  json.name_with_zone @cart.table_name_with_zone
  json.ban_product_ids @cart.table.weixin_ban_product_ids rescue []
end
