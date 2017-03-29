class ClearDirtyTables < ActiveRecord::Migration
  def change
    Ddt::Table.joins("left join ddt_table_zones on ddt_table_zones.id = ddt_tables.table_zone_id").where("ddt_table_zones.id is NULL").destroy_all
  end
end
