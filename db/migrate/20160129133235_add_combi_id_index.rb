class AddCombiIdIndex < ActiveRecord::Migration
  def change
    add_index :ddt_combo_items_variants, :combi_id
  end
end
