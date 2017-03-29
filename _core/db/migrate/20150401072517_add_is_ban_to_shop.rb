class AddIsBanToShop < ActiveRecord::Migration
  def change
    add_column :ddt_shops, :is_ban, :boolean, :default => false
  end
end
