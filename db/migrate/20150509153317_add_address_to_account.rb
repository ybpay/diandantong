class AddAddressToAccount < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_accounts, :address
      add_column :ddt_accounts, :address, :string
    end
  end
end
