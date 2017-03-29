class AddUpdatedIndex < ActiveRecord::Migration
  def change
    add_index :ddt_orders, [:branch_id, :updated_at], name: "index_orders_on_bid_and_updated_at"
    add_index :ddt_line_items, [:branch_id, :updated_at], name: "index_line_items_on_bid_and_updated_at"
    add_index :ddt_pay_items, [:branch_id, :updated_at], name: "index_pay_items_on_bid_and_updated_at"
    add_index :ddt_line_item_trace_points, [:branch_id, :updated_at], name: "index_litps_on_bid_and_updated_at"
    add_index :ddt_order_change_logs, [:branch_id, :updated_at], name: "index_ocls_on_bid_and_updated_at"
    add_index :ddt_adjustments, [:branch_id, :updated_at], name: "index_adjustments_on_bid_and_updated_at"
  end
end
