class AddInxForCsUpdate < ActiveRecord::Migration
  def change
    add_index :ddt_combo_package_items, [:branch_id, :updated_at], name: 'cpkgi_branch_id_updated_at'
  end
end
