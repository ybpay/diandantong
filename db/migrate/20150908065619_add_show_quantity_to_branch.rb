class AddShowQuantityToBranch < ActiveRecord::Migration
  def change
    add_column :ddt_branches, :show_stock_quantity, :boolean, default: true
    add_column :ddt_branches, :show_sale_quantity, :boolean, default: true
  end
end
