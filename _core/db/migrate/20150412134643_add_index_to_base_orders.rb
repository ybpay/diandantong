class AddIndexToBaseOrders < ActiveRecord::Migration
  def change
  	change_column :ddt_orders, :state, :string, limit: 100
  	add_index :ddt_orders, :state, using: :btree
  	add_index :ddt_orders, :updated_at, using: :btree
  	add_index :ddt_orders, :placed_at, using: :btree
  	change_column :ddt_orders, :track_from, :string, limit: 100
  	add_index :ddt_orders, :track_from, using: :btree
  end
end
