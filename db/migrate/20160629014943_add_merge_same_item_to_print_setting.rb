class AddMergeSameItemToPrintSetting < ActiveRecord::Migration
  def change
    add_column :ddt_print_settings, :merge_same_item, :boolean, default: false
  end
end
