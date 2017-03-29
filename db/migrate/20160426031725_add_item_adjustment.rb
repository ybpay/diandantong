class AddItemAdjustment < ActiveRecord::Migration
  def up
    add_column :ddt_line_items, :adjustment_total, :decimal, precision: 8, scale: 2, default: 0.0 unless column_exists? :ddt_line_items, :adjustment_total
    unless column_exists? :ddt_adjustments, :parent_id
      add_column :ddt_adjustments, :parent_id, :integer
      add_index :ddt_adjustments, :parent_id
    end
    unless column_exists? :ddt_adjustments, :line_item_id
      add_column :ddt_adjustments, :line_item_id, :integer
      add_index :ddt_adjustments, :line_item_id
    end
  end

  def down
    remove_column :ddt_line_items, :adjustment_total, :decimal, precision: 8, scale: 2, default: 0.0
    remove_column :ddt_adjustments, :parent_id, :integer
    remove_column :ddt_adjustments, :line_item_id, :integer
  end
end
