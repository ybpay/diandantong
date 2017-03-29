json.array! @orders do |order|
  json.partial! partial: '/ddt/weixin/user/order/base_order', locals: { order: order}
  json.extract! order, :table_id, :table_name_with_zone, :table_name
end