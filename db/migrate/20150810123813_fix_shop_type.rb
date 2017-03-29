class FixShopType < ActiveRecord::Migration
  def change
    Ddt::Shop.where("shop_type is null and max_branches_limit = 1").update_all(shop_type: :single)
    Ddt::Shop.where("shop_type is null and max_branches_limit >= 100").update_all(shop_type: :multiple)
    Ddt::Shop.where("shop_type is null and max_branches_limit > 1 and max_branches_limit < 100").update_all(shop_type: :chain)
  end
end
