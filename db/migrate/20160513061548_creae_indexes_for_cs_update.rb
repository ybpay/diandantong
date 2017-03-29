class CreaeIndexesForCsUpdate < ActiveRecord::Migration
  def change
    add_index :ddt_categories, :deleted_at unless index_exists? :ddt_categories, :deleted_at
  end
end
