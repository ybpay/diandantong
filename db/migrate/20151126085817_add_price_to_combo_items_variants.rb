class AddPriceToComboItemsVariants < ActiveRecord::Migration
  def change
    add_column :ddt_combo_items_variants, :price, :decimal, scale: 2, precision: 8, default: 0.0
    add_column :ddt_combo_items_variants, :vip_price, :decimal, scale: 2, precision: 8, default: 0.0
    add_column :ddt_combo_items_variants, :original_price, :decimal, scale: 2, precision: 8, default: 0.0
  end
end
