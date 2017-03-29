class AddCostPrictToComboItemVariants < ActiveRecord::Migration
  def change
    add_column :ddt_combo_items_variants, :cost_price, :decimal, scale: 2, precision: 8, default: 0.0
  end
end
