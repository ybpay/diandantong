class AddUpdatedAtIndexToComboPackages < ActiveRecord::Migration
  def change
    add_index :ddt_combo_packages, :updated_at
  end
end
