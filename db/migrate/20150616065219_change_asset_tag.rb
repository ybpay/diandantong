class ChangeAssetTag < ActiveRecord::Migration
  def change
    create_table :ddt_assets_asset_tags do |t|
      t.references :asset, index: true
      t.references :asset_tag, index: true
    end

    remove_column :ddt_assets, :asset_tag_id
    add_column :ddt_asset_tags, :count, :integer, default: 0
  end
end
