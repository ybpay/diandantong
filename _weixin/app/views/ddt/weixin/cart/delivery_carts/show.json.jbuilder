json.partial! partial: '/ddt/weixin/cart/base_cart', locals: { cart: @cart }
json.(@cart, :shipment_total)
json.shipment do
  json.(@cart.shipment, :address_id, :delivery_zone_id, :cost, :delivery_time_id, :delivery_date)
end