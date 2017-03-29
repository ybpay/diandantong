json.user_name @order.name
json.gender_name @order.gender_name
json.table_zone_name @order.table_zone.name
json.is_my_order @is_my_order
json.opinion @opinion unless @is_my_order
if @order.reservation_info.try(:table)
  json.reservation_table_str "（#{@order.reservation_info.table.try(:name)}）"
end

json.extract! @order, :reservation_date_str, :reservation_time_point_str
json.agree_guests do
  json.array! @order.agree_guests, :nickname, :headimgurl, :sex
end
json.disagree_guests do
  json.array! @order.disagree_guests, :nickname, :headimgurl, :sex
end

