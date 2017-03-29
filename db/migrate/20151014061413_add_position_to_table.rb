class AddPositionToTable < ActiveRecord::Migration
  def change
    add_column :ddt_tables, :position, :integer, default: 50
  end
end
