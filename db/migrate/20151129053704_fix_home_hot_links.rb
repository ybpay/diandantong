class FixHomeHotLinks < ActiveRecord::Migration
  def change
    Ddt::HomeHotLink.where(shop_type: [:single, :service]).update_all(shop_type: Ddt::Shop::SHOP_TYPE_STANDARD)
  end
end
