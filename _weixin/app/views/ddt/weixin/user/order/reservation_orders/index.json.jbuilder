json.array! @orders do |order|
  json.partial! partial: '/ddt/weixin/user/order/base_order', locals: { order: order}
  json.extract! order, :prepayment_type, :reservation_date_str, :reservation_time_point_str,
                       :table_zone_name, :name, :phone, :gender_name, :amount_for_pay
end