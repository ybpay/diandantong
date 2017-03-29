class AddCombiIdToComboItemsVariants < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_combo_items_variants, :combi_id
      add_column :ddt_combo_items_variants, :combi_id, :string
      ActiveRecord::Base.connection.execute <<-SQL
        UPDATE ddt_combo_items_variants SET combi_id=CONCAT(combo_item_id, ':', variant_id);
      SQL
    end
  end
end
