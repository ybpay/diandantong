class RemoveCostPriceToCombo < ActiveRecord::Migration
  def change
    remove_column :ddt_combo_items, :cost_price, :decimal, precision: 8, scale: 2, default: 0.0
    remove_column :ddt_combo_items_variants, :cost_price, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
