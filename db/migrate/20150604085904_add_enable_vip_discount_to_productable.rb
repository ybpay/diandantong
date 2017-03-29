class AddEnableVipDiscountToProductable < ActiveRecord::Migration
  def change
    add_column :ddt_products, :enable_vip_discount, :boolean, default: true
    add_column :ddt_combos, :enable_vip_discount, :boolean, default: true
  end
end
