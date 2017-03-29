class AddIndexToLitp < ActiveRecord::Migration
  def change
    add_index :ddt_line_item_trace_points, [:branch_id, :created_at], name: "index_litp_on_bid_and_created_at"
  end
end
