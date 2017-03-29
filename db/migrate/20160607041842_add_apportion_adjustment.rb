class AddApportionAdjustment < ActiveRecord::Migration
  def change
    add_column :ddt_line_items, :apportion_adjust_reason, :string, default: ""
    add_column :ddt_line_items, :apportion_adjustment_total, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :ddt_adjustments, :is_apportion, :boolean, default: false
  end
end
