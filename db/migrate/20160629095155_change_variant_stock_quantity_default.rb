class ChangeVariantStockQuantityDefault < ActiveRecord::Migration
  def change
    change_column :ddt_variants, :stock_quantity, :integer, default: 999999
  end
end
