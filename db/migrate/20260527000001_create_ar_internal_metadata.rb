# frozen_string_literal: true

# This migration ensures the ar_internal_metadata table exists for Rails 5.0+.
# It is auto-created by ActiveRecord on first db:migrate but we add it explicitly
# to ensure smooth upgrades.

class CreateArInternalMetadata < ActiveRecord::Migration[4.2]
  def up
    return if connection.table_exists?(:ar_internal_metadata)

    create_table :ar_internal_metadata do |t|
      t.string :key, null: false
      t.string :value
      t.timestamps null: false
    end

    add_index :ar_internal_metadata, :key, unique: true, name: :index_ar_internal_metadata_on_key
  end

  def down
    drop_table :ar_internal_metadata if connection.table_exists?(:ar_internal_metadata)
  end
end
