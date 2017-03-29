class FixShopData < ActiveRecord::Migration
  def change
    Ddt::Shop.where(shop_type: [:single, :service]).update_all(shop_type: :standard)
  end
end
