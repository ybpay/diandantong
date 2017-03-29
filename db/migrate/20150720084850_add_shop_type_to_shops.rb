class AddShopTypeToShops < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shops, :shop_type
      add_column :ddt_shops, :shop_type, :string
      Ddt::Shop.where("max_branches_limit = 1").update_all(shop_type: :single)
      Ddt::Shop.where("max_branches_limit >= 100").update_all(shop_type: :multiple)
      Ddt::Shop.where("shop_type is null").update_all(shop_type: :chain)
    end
  end
end
