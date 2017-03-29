class AddIndexToOrder < ActiveRecord::Migration
  def change
    add_index :ddt_orders, [:branch_id, :state]
    add_index :ddt_orders, [:branch_id, :placed_at]
  end
end
