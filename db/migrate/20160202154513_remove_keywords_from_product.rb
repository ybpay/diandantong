class RemoveKeywordsFromProduct < ActiveRecord::Migration
  def change
  	remove_column :ddt_products, :keywords
  	remove_column :ddt_combos, :keywords
  end
end
