class AddShipmentInfoToOrder < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_orders, :delivery_name
      sql = ActiveRecord::Base.connection()
      sql.execute "SET autocommit=0"
      sql.begin_db_transaction
      sql.execute("CREATE TABLE ddt_orders_new LIKE ddt_orders")
      add_column :ddt_orders_new, :delivery_name, :string
      add_column :ddt_orders_new, :delivery_phone, :string
      add_column :ddt_orders_new, :delivery_address, :string
      add_column :ddt_orders_new, :delivery_zone_name, :string
      add_column :ddt_orders_new, :delivery_date, :datetime
      add_column :ddt_orders_new, :delivery_time_display, :string
      # 20160130100016_add_reservation_info_to_order
      add_column :ddt_orders_new, :reservation_table_zone_name, :string
      add_column :ddt_orders_new, :reservation_table_name, :string
      add_column :ddt_orders_new, :reservation_date, :datetime
      add_column :ddt_orders_new, :reservation_time_point_display, :string
      add_column :ddt_orders_new, :reservation_name, :string
      add_column :ddt_orders_new, :reservation_phone, :string
      add_column :ddt_orders_new, :reservation_gender, :string
      # 20160130100017_add_vip_discount_to_order
      add_column :ddt_orders_new, :vip_discount, :decimal, precision: 8, scale: 2, default: 1.0
      # 20160130100021_add_table_name_to_order
      add_column :ddt_orders_new, :table_name, :string
      add_column :ddt_orders_new, :table_zone_name, :string

      sql.execute <<-SQL
        INSERT INTO ddt_orders_new
          SELECT *,
            null, null, null, null, null, null,
            null, null, null, null, null, null, null,
            1.0,
            null, null
          FROM ddt_orders where ddt_orders.placed_at is not null;
      SQL
      rename_table :ddt_orders, :ddt_orders_old
      rename_table :ddt_orders_new, :ddt_orders
      sql.commit_db_transaction
      sql.execute "SET autocommit=1"
    end
    execute <<-SQL.strip_heredoc
      ALTER TABLE ddt_orders CHANGE COLUMN `delivery_address`
        `delivery_address` varchar(300) CHARACTER
        SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    SQL
    execute <<-SQL
      UPDATE ddt_orders o
      LEFT JOIN ddt_shipments s ON s.order_id = o.id
      LEFT JOIN ddt_delivery_zones z ON z.id = s.delivery_zone_id
      LEFT JOIN ddt_delivery_times t ON t.id = s.delivery_time_id
      SET
        o.delivery_name = s.name,
        o.delivery_phone = s.phone,
        o.delivery_address = s.content,
        o.delivery_zone_name = z.zone_name,
        o.delivery_date = s.delivery_date,
        o.delivery_time_display = IF(
          t.id IS NOT NULL,
          CONCAT(DATE_FORMAT(t.start_time, '%H:%i'), '~', DATE_FORMAT(t.end_time, '%H:%i')),
          NULL)
      where o.type = "Ddt::DeliveryOrder" and o.placed_at is not null;
    SQL
  end

  def down
    drop_table :ddt_orders
    rename_table :ddt_orders_old, :ddt_orders
  end
end
