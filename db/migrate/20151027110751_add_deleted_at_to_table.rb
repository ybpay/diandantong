class AddDeletedAtToTable < ActiveRecord::Migration
  def change
    add_column :ddt_tables, :deleted_at, :datetime
  end
end
