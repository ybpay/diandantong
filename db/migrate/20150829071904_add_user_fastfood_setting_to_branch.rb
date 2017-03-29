class AddUserFastfoodSettingToBranch < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_branches, :use_fastfood_setting
      add_column :ddt_branches, :use_fastfood_setting, :boolean, default: false
    end
  end
end
