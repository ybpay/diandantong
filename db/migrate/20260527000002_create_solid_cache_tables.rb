# frozen_string_literal: true

class CreateSolidCacheTables < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_cache_entries, id: :primary_key do |t|
      t.binary   :key, null: false, limit: 1024
      t.binary   :value, null: false, limit: 512.megabytes
      t.datetime :created_at, null: false

      t.index [:key], name: :index_solid_cache_entries_on_key, unique: true
    end
  end
end
