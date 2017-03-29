class AddColumnToShops < ActiveRecord::Migration
  def change
  	add_column :ddt_shops, :wifi_users_count, :integer
  end
end
