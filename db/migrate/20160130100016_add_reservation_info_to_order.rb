class AddReservationInfoToOrder < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ddt_orders o
      SET
        reservation_name = info.name,
        reservation_phone = info.phone,
        reservation_gender = info.gender,
        reservation_table_zone_name = tz.name,
        reservation_table_name = t.name,
        reservation_date = info.reservation_date,
        reservation_time_point_display = TO_CHAR(info.time_point, 'HH24:MI')
      FROM ddt_reservation_infos info
      LEFT JOIN ddt_table_zones tz ON tz.id = info.table_zone_id
      LEFT JOIN ddt_tables t ON t.id = info.table_id
      WHERE info.reservation_order_id = o.id
        AND o.type = 'Ddt::ReservationOrder'
        AND o.placed_at IS NOT NULL;
    SQL
  end

  def down
  end
end
