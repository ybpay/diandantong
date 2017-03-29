class FixIndex < ActiveRecord::Migration
  def up
    unless index_exists? :ddt_order_itemables, [:table_id, :store_type]
      add_index :ddt_order_itemables, [:table_id, :store_type]
    end
  end

  def down
    if index_exists? :ddt_order_itemables, [:table_id, :store_type]
      remove_index :ddt_order_itemables, [:table_id, :store_type]
    end
  end
end
