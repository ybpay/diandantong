json.cache! @order.cache_key, expires_in: 2.hours do
  json.partial! partial: '/ddt/webpos/order/base_show', locals: { order: @order }
  json.extract! @order, :note, :prepayment_type
  json.reservation_info do
    json.(@order.reservation_info, :name, :phone, :gender, :table_zone_id, :table_id, :reservation_date, :reservation_time_point_id)
  end
end
