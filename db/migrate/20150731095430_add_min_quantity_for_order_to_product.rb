class AddMinQuantityForOrderToProduct < ActiveRecord::Migration
  def change
    add_column :ddt_products, :min_quantity_for_order, :integer, default: 1
  end
end
