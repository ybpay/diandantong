class AddAddressIndexToShop < ActiveRecord::Migration
  def change
  	if column_exists? :ddt_shops, :address
  		change_column :ddt_shops, :address, :string, limit: 191
  	end
    add_index :ddt_shops, :address
  end
end
