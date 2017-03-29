class RenameEnableVipDiscount < ActiveRecord::Migration
  def change
    rename_column :ddt_products, :enable_vip_discount, :enable_discount
    rename_column :ddt_combos, :enable_vip_discount, :enable_discount
  end
end
