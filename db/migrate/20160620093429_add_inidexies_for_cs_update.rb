class AddInidexiesForCsUpdate < ActiveRecord::Migration
  def change
    add_index :ddt_combo_package_items, :updated_at
  end
end
