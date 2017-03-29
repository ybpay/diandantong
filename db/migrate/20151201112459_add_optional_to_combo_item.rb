class AddOptionalToComboItem < ActiveRecord::Migration
  def change
    add_column :ddt_combo_items, :optional, :boolean, default: true
    add_column :ddt_combo_items, :price_strategy, :string, default: 'fixed_price'
    add_column :ddt_combo_items, :price, :decimal, scale: 2, precision: 8, default: 0.0
    add_column :ddt_combo_items, :vip_price, :decimal, scale: 2, precision: 8, default: 0.0
    add_column :ddt_combo_items, :original_price, :decimal, scale: 2, precision: 8, default: 0.0
    add_column :ddt_combo_items, :cost_price, :decimal, scale: 2, precision: 8, default: 0.0

  end
end
