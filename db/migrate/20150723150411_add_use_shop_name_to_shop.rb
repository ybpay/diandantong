class AddUseShopNameToShop < ActiveRecord::Migration
  def change
    add_column :ddt_shops, :use_shop_name_for_queue, :boolean, default: false
  end
end
