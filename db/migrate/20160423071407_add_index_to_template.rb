class AddIndexToTemplate < ActiveRecord::Migration
  def change
    add_index :ddt_bill_template_settings, :branch_id
    add_index :impressions, [:created_at, :impressionable_type, :impressionable_id, :request_hash], name: "index_imp_on_ciir"
    add_index :impressions, [:created_at, :impressionable_type, :impressionable_id, :user_id], name: "index_imp_on_ciiu"
  end
end
