class RemovePromotionable < ActiveRecord::Migration
  def change
    remove_column :ddt_products, :promotionable, :boolean, default: true
    remove_column :ddt_combos, :promotionable, :boolean, default: true
  end
end
