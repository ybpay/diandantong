class AddEnableChangePriceToItemable < ActiveRecord::Migration
  def change
    add_column :ddt_products, :enable_change_price, :boolean, default: false
    add_column :ddt_combos, :enable_change_price, :boolean, default: false
  end
end
