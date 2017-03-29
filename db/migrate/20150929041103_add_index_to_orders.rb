class AddIndexToOrders < ActiveRecord::Migration

  def up
  	if index_exists? :ddt_orders, :name => "order_shop_branch_index"
  		remove_index :ddt_orders, :name => "order_shop_branch_index"
  	end
  	remove_index :ddt_orders, [:branch_id, :state]
  	remove_index :ddt_orders, [:branch_id, :placed_at]
  	remove_index :ddt_orders, :branch_id
  	add_index :ddt_orders, [:branch_id, :state, :placed_at]
  	add_index :ddt_orders, [:shop_id, :state, :branch_id], :name => "order_shop_state_index"
  end

  def down

  	remove_index :ddt_orders, :name => "order_shop_state_index"
  end
end
