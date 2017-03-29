class FixTelephoneToShop < ActiveRecord::Migration
  def change
  	change_column :ddt_shops, :telephone, :string, limit: 191
  	add_index :ddt_shops, :telephone, unique: true
  end
end
