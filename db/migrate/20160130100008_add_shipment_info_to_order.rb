class AddShipmentInfoToOrder < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_orders, :delivery_name
      add_column :ddt_orders, :delivery_name, :string
      add_column :ddt_orders, :delivery_phone, :string
      add_column :ddt_orders, :delivery_address, :string
      add_column :ddt_orders, :delivery_zone_name, :string
      add_column :ddt_orders, :delivery_date, :datetime
      add_column :ddt_orders, :delivery_time_display, :string
      # 20160130100016_add_reservation_info_to_order
      add_column :ddt_orders, :reservation_table_zone_name, :string
      add_column :ddt_orders, :reservation_table_name, :string
      add_column :ddt_orders, :reservation_date, :datetime
      add_column :ddt_orders, :reservation_time_point_display, :string
      add_column :ddt_orders, :reservation_name, :string
      add_column :ddt_orders, :reservation_phone, :string
      add_column :ddt_orders, :reservation_gender, :string
      # 20160130100017_add_vip_discount_to_order
      add_column :ddt_orders, :vip_discount, :decimal, precision: 8, scale: 2, default: 1.0
      # 20160130100021_add_table_name_to_order
      add_column :ddt_orders, :table_name, :string
      add_column :ddt_orders, :table_zone_name, :string
    end
    execute <<-SQL
      UPDATE ddt_orders o
      SET
        delivery_name = s.name,
        delivery_phone = s.phone,
        delivery_address = s.content,
        delivery_zone_name = z.zone_name,
        delivery_date = s.delivery_date,
        delivery_time_display = CASE
          WHEN t.id IS NOT NULL THEN TO_CHAR(t.start_time, 'HH24:MI') || '~' || TO_CHAR(t.end_time, 'HH24:MI')
          ELSE NULL
        END
      FROM ddt_shipments s
      LEFT JOIN ddt_delivery_zones z ON z.id = s.delivery_zone_id
      LEFT JOIN ddt_delivery_times t ON t.id = s.delivery_time_id
      WHERE s.order_id = o.id
        AND o.type = 'Ddt::DeliveryOrder'
        AND o.placed_at IS NOT NULL;
    SQL
  end

  def down
    remove_column :ddt_orders, :delivery_name
    remove_column :ddt_orders, :delivery_phone
    remove_column :ddt_orders, :delivery_address
    remove_column :ddt_orders, :delivery_zone_name
    remove_column :ddt_orders, :delivery_date
    remove_column :ddt_orders, :delivery_time_display
    remove_column :ddt_orders, :reservation_table_zone_name
    remove_column :ddt_orders, :reservation_table_name
    remove_column :ddt_orders, :reservation_date
    remove_column :ddt_orders, :reservation_time_point_display
    remove_column :ddt_orders, :reservation_name
    remove_column :ddt_orders, :reservation_phone
    remove_column :ddt_orders, :reservation_gender
    remove_column :ddt_orders, :vip_discount
    remove_column :ddt_orders, :table_name
    remove_column :ddt_orders, :table_zone_name
  end
end
