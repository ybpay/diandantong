class CreateKitchenSetting < ActiveRecord::Migration
  def change
    create_table :ddt_kitchen_settings do |t|
      t.references :shop, index: true
      t.references :branch, index: true
      t.integer :warning_wait_minitue, default: 30
      t.timestamps
    end unless table_exists? :ddt_kitchen_settings

    Ddt::Branch.all.find_each do |branch|
      branch.create_kitchen_setting if branch.kitchen_setting.blank?
    end
  end
end
