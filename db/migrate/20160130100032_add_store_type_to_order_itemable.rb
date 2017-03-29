class AddStoreTypeToOrderItemable < ActiveRecord::Migration
  def up
    add_column :ddt_order_itemables, :store_type, :string unless column_exists? :ddt_order_itemables, :store_type
    add_column :ddt_order_itemables, :table_id, :integer unless column_exists? :ddt_order_itemables, :table_id
    execute <<-SQL
      update ddt_order_itemables set store_type = "pre_order";
    SQL
  end

  def down
    remove_column :ddt_order_itemables, :store_type, :string if column_exists? :ddt_order_itemables, :store_type
    remove_column :ddt_order_itemables, :table_id, :integer if column_exists? :ddt_order_itemables, :table_id
  end
end
