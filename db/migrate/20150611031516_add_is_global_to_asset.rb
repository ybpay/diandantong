class AddIsGlobalToAsset < ActiveRecord::Migration
  def change
    add_column :ddt_assets, :is_global, :boolean, default: false
    add_column :ddt_assets, :asset_tag_id, :integer
    add_index :ddt_assets, :asset_tag_id
    create_table :ddt_asset_tags do |t|
      t.string :name
      t.timestamps
    end
  end
end
