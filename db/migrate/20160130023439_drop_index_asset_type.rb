class DropIndexAssetType < ActiveRecord::Migration
  def change
    remove_index :ddt_assets, column: :type
  end
end
