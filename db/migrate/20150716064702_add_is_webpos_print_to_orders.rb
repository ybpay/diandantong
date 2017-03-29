class AddIsWebposPrintToOrders < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_orders, :is_webpos_printed
      add_column :ddt_orders, :is_webpos_printed, :boolean, default: false
    end
  end
end
