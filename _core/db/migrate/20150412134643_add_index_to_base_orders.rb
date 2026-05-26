class AddIndexToBaseOrders < ActiveRecord::Migration
  def change
  	change_column :ddt_orders, :state, :string, limit: 100
  	add_index :ddt_orders, :state
  	add_index :ddt_orders, :updated_at
  	add_index :ddt_orders, :placed_at
  	change_column :ddt_orders, :track_from, :string, limit: 100
  	add_index :ddt_orders, :track_from
  end
end
