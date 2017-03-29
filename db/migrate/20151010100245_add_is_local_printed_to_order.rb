class AddIsLocalPrintedToOrder < ActiveRecord::Migration
  def change
    add_column :ddt_orders, :is_local_printed, :boolean, default: false
  end
end
