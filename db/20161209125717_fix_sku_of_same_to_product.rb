class FixSkuOfSameToProduct < ActiveRecord::Migration
  def change
    sql = "select branch_id, sku as counter_of_id from ddt_variants where is_master = 0 and deleted_at is NULL group by sku, branch_id having count(id) > 1"
    result = ActiveRecord::Migration.connection.execute(sql).to_a
    result.map do |branch_id_with_sku|
      Ddt::Variant.where(branch_id: branch_id_with_sku[0], sku: branch_id_with_sku[1]).slice(1..-1).each do |variant|
        variant.sku = variant.id
        variant.save!
      end
    end
  end
end
