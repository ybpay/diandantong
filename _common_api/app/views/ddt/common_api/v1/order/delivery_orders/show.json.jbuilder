json.cache! @order.cache_key, expires_in: 2.hours do
  json.partial! partial: '/ddt/common_api/v1/order/base_show', locals: { order: @order }
  json.shipment do 
    json.extract! @order.shipment, :id, :delivery_man_id, :state, :shipping_at, :shipped_at, :name, :phone, :latitude, :longitude, :note, :delivery_date
  end
end
