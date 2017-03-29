class AddTableNameToOrder < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE ddt_orders o
      LEFT JOIN ddt_tables t ON t.id = o.table_id
      LEFT JOIN ddt_table_zones tz ON tz.id = t.table_zone_id
      SET
        o.table_name = t.name,
        o.table_zone_name = tz.name
      where o.type = "Ddt::EatInHallOrder" and o.placed_at is not null;
    SQL
  end

  def down
  end
end
