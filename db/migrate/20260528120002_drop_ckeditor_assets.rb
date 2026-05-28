class DropCkeditorAssets < ActiveRecord::Migration[8.1]
  def up
    drop_table :ckeditor_assets if table_exists?(:ckeditor_assets)
  end

  def down
    create_table "ckeditor_assets" do |t|
      t.string   "data_file_name",               null: false
      t.string   "data_content_type"
      t.integer  "data_file_size"
      t.integer  "assetable_id"
      t.string   "assetable_type",    limit: 30
      t.string   "type",              limit: 30
      t.integer  "width"
      t.integer  "height"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable"
    add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type"
  end
end
