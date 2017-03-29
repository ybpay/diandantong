class FixTableIndex < ActiveRecord::Migration
  def change
    add_index :ddt_tables, [:branch_id, :updated_at], name: "index_tables_on_bid_and_updated_at"
    remove_index :ddt_tables, :branch_id
  end
end
