class FixIndexOfAssets < ActiveRecord::Migration
  def change
  	change_column :ddt_assets, :type, :string, limit:100
  	add_index :ddt_assets, :type
  	add_index :ddt_assets, :position
  end
end
