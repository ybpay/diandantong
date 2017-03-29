class RemoveTableBindIdFromTable < ActiveRecord::Migration
  def change
    remove_column :ddt_tables, :table_bind_id
    drop_table :ddt_table_binds    
  end
end
