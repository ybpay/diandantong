class AddItemableNameToComboPackage < ActiveRecord::Migration
  def change
    add_column :ddt_combo_packages, :itemable_name, :string
  end
end
