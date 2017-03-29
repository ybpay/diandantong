class AddComboIdToComboPackageItem < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_combo_package_items, :combo_id
      add_column :ddt_combo_package_items, :combo_id, :integer
    end
    Ddt::ComboPackageItem.joins(:combo_package).update_all('ddt_combo_package_items.combo_id = ddt_combo_packages.combo_id')
  end
end
