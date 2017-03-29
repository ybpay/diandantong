class AddCreatedAtIndexToOrders < ActiveRecord::Migration
  def change
    add_index :ddt_orders, :created_at
  end
end
