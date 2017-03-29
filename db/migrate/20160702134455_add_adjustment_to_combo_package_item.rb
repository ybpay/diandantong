class AddAdjustmentToComboPackageItem < ActiveRecord::Migration
  def change
    add_column :ddt_combo_package_items, :adjustment_total, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :ddt_combo_package_items, :apportion_adjustment_total, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :ddt_combo_package_items, :not_actual_amount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
