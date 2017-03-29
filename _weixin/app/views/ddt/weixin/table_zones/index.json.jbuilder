json.array! @table_zones do |table_zone|
  json.extract! table_zone, :id, :name, :min_reservation_price, :tables_count_for_reservation, :tables_count, :reservation_price, :reservation_price_percent
  json.reservation_time_points table_zone.reservation_time_points do |reservation_time_point|
    json.id reservation_time_point.id
    json.time_point reservation_time_point.time_point.strftime("%H:%M")
    json.is_sale_outs reservation_time_point.order_counts_in_max_reservation_days.each_with_index.map{|count, index|
      if index == 0
        !reservation_time_point.valid_today? || count >= table_zone.tables_count_for_reservation
      else
        count >= table_zone.tables_count_for_reservation
      end
    }
  end
end