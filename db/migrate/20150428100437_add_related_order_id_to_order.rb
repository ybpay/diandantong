class AddRelatedOrderIdToOrder < ActiveRecord::Migration
  def change
    add_column :ddt_orders, :related_order_id, :integer
    add_index :ddt_orders, :related_order_id
  end
end
