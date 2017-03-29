class FixTimestamp < ActiveRecord::Migration
  def change
    change_column :ddt_orders, :updated_at, :datetime, :limit => 6
    change_column :ddt_tables, :updated_at, :datetime, :limit => 6
    change_column :ddt_order_itemables, :updated_at, :datetime, :limit => 6
    change_column :ddt_pay_items, :updated_at, :datetime, :limit => 6
    change_column :ddt_line_items, :updated_at, :datetime, :limit => 6
  end
end
