class FixAssetsIndex < ActiveRecord::Migration
  def change
    remove_index :ddt_assets, name: 'index_ddt_assets_on_type_and_viewable_type'
  end
end
