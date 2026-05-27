# frozen_string_literal: true

class CreateApplicationRecord < ActiveRecord::Migration[8.1]
  def up
    # ApplicationRecord is a virtual base class; no table needed.
    # This migration establishes the baseline for Rails 8.1 schema.
    # All existing migrations are considered already migrated.
    # The schema version will be set by running this migration.
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
