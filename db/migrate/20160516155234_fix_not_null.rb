class FixNotNull < ActiveRecord::Migration
  def change
    change_column :ddt_line_items, :adjustment_total, :decimal, precision: 8, scale: 2, default: 0.0, null: false
    change_column :ddt_line_items, :move_quantity, :integer, default: 0, null: false
  end
end
