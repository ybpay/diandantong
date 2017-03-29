class FixOrderIndex < ActiveRecord::Migration
  def change
  	remove_index :ddt_orders, :shop_id
  	add_index :ddt_orders, [:shop_id, :branch_id], name: "order_shop_branch_index"
  end
end
