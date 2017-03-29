class AddCustomIndexToShop < ActiveRecord::Migration
  def change
    add_index :ddt_shops, :custom_domain
  end
end
