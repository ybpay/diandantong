class AddBranchIdTypeIndexToOrder < ActiveRecord::Migration
  def change
    add_index :ddt_orders, [:branch_id, :type, :placed_at], name: "index_orders_on_bid_type_placed_at", :length => {:type => 100}
    add_index :ddt_orders, [:branch_id, :placed_at], name: "index_orders_on_bid_placed_at"
  end
end
