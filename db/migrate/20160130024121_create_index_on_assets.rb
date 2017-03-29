class CreateIndexOnAssets < ActiveRecord::Migration
  def change
    add_index :ddt_assets, :created_at
  end
end
