class MigrateShopType < ActiveRecord::Migration
  def change
    Ddt::Shop.where(shop_type: nil).update_all(shop_type: :single)
    change_column :ddt_shops, :shop_type, :string, default: :single
  end
end
