json.array! @table_zones do |table_zone|
  json.extract! table_zone, :id, :name, :tables_count_for_reservation, :tables_count
  json.reservation_time_points table_zone.reservation_time_points do |reservation_time_point|
    json.id reservation_time_point.id
    json.table_zone_name table_zone.name
    json.time_point reservation_time_point.time_point.strftime("%H:%M")
    order_counts = reservation_time_point.order_counts_in_max_reservation_days
    json.orders_counts order_counts
    json.remain_table_counts order_counts.map{|count| table_zone.tables_count_for_reservation - count }
    json.can_order_today reservation_time_point.valid_today?
  end
end