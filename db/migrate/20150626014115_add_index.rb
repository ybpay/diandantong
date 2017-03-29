class AddIndex < ActiveRecord::Migration
  def change
  	change_column :ddt_shops, :slug, :string, limit: 191
    add_index :ddt_shops, :slug
    add_index :ddt_variants, :sale_quantity
  end
end
