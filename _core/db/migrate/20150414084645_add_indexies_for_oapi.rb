class AddIndexiesForOapi < ActiveRecord::Migration
  def change
    add_index :ddt_categories, :updated_at
    add_index :ddt_products, :updated_at
  end
end
