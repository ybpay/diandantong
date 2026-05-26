class CreateCacheVersion < ActiveRecord::Migration
  def change
    create_table :ddt_cache_versions do |t|
      t.string :scope_type
      t.integer :scope_id
      t.string :key
      t.datetime :updated_at
    end

    add_index :ddt_cache_versions, [:scope_type, :scope_id, :key], name: :index_of_cache_versions_scope_key
  end
end
