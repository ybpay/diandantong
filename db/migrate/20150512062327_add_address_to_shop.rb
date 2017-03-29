class AddAddressToShop < ActiveRecord::Migration
  def change
    if column_exists? :ddt_accounts, :address
      remove_column :ddt_accounts, :address
    end
    unless column_exists? :ddt_shops, :address
      add_column :ddt_shops, :address, :string
    end
  end
end
