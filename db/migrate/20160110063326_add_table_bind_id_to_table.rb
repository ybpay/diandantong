class AddTableBindIdToTable < ActiveRecord::Migration
  def change
    add_column :ddt_tables, :table_bind_id, :integer
  end
end
