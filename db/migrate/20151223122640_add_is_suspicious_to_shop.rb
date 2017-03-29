class AddIsSuspiciousToShop < ActiveRecord::Migration
  def change
    add_column :ddt_shops, :is_suspicious, :boolean, default: false
  end
end
