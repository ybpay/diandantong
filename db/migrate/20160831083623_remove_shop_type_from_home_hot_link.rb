class RemoveShopTypeFromHomeHotLink < ActiveRecord::Migration
  def change
    remove_column :ddt_home_hot_links, :shop_type
  end
end
