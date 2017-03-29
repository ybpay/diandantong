class AddIndexToComment < ActiveRecord::Migration
  def change
    add_index :ddt_comments, [:commentable_type, :commentable_id], name: "index_comments_on_commentable"
    add_index :ddt_subtract_reasons, :shop_id
    add_index :ddt_order_change_logs, [:branch_id, :created_at], name: "index_ocls_on_bid_and_created_at"
  end
end
