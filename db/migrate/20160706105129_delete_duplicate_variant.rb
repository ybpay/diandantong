class DeleteDuplicateVariant < ActiveRecord::Migration
  def change
    sql = <<SQL
  select a.id, a.combi_id from ddt_combo_items_variants a, ddt_combo_items_variants b where a.id != b.id and a.combi_id = b.combi_id;
SQL
    r = Ddt::ComboItemsVariant.find_by_sql(sql)

    hash = {}
    id_to_removed = []
    r.each do |it|
      id = hash[it.combi_id]
      if id.present?
        id_to_removed << it.id
      else
        hash[it.combi_id] = it.id
      end
    end

    combo_item_ids = hash.keys.map{|it| it.split(':')[0].to_i}
    combo_ids = Ddt::ComboItem.select('combo_id').where(id: combo_item_ids).map(&:combo_id)
    Ddt::ComboItemsVariant.where(id: id_to_removed).delete_all
    Ddt::Combo.where(id: combo_ids).update_all(updated_at: Time.now)
    remove_index :ddt_combo_items_variants, :combi_id
    add_index :ddt_combo_items_variants, :combi_id, name: "index_ddt_combo_items_variants_on_combi_id", unique: true
  end
end
