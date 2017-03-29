json.cache! @order.cache_key, expires_in: 2.hours do
  json.partial! partial: '/ddt/common_api/v1/order/base_show', locals: { order: @order }
end
