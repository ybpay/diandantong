class AddIndexToCategories < ActiveRecord::Migration
  def change
    add_index :ddt_categories, :parent_id
    add_index :ddt_categories, :position
  end
end
