class AddDeleteByAdminMark < ActiveRecord::Migration
  def change
    tables = [:ddt_shifts, :ddt_shift_items, :ddt_orders, :ddt_line_items, :ddt_order_change_logs, :ddt_pay_items]
    tables.each do |table_name|
      add_column table_name, :delete_by_admin, :boolean, default: false
    end
    tables.pop
    tables.each do |table_name|
      add_column table_name, :deleted_at, :datetime
    end
  end
end
