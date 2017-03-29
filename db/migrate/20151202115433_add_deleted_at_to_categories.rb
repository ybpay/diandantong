class AddDeletedAtToCategories < ActiveRecord::Migration
  def change
    add_column :ddt_categories, :deleted_at, :datetime
  end
end
