json.partial! partial: '/ddt/weixin/cart/base_cart', locals: { cart: @cart }
json.extract! @cart, :reservation_phone, :reservation_name, :reservation_gender, :reservation_date, :reservation_date_str, :reservation_time_point_str
json.table_zone do
  json.min_reservation_price      @cart.table_zone.try(:min_reservation_price)
  json.reservation_price          @cart.table_zone.try(:reservation_price)
  json.reservation_price_percent  @cart.table_zone.try(:reservation_price_percent)
  json.name                       @cart.table_zone.try(:name)
end
