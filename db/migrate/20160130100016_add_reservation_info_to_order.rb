class AddReservationInfoToOrder < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ddt_orders o
      LEFT JOIN ddt_reservation_infos info ON info.reservation_order_id = o.id
      LEFT JOIN ddt_table_zones tz ON tz.id = info.table_zone_id
      LEFT JOIN ddt_tables t ON t.id = info.table_id
      SET
        o.reservation_name = info.name,
        o.reservation_phone = info.phone,
        o.reservation_gender = info.gender,
        o.reservation_table_zone_name = tz.name,
        o.reservation_table_name = t.name,
        o.reservation_date = info.reservation_date,
        o.reservation_time_point_display = DATE_FORMAT(info.time_point, '%H:%i')
      where o.type = "Ddt::ReservationOrder" and o.placed_at is not null;
    SQL
  end

  def down
  end
end
