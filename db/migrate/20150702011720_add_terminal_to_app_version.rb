class AddTerminalToAppVersion < ActiveRecord::Migration
  def change
    add_column :ddt_app_versions, :terminal, :string, default: 'phone' unless column_exists? :ddt_app_versions, :terminal
    add_index :ddt_app_versions, :terminal unless column_exists? :ddt_app_versions, :terminal
    change_column :ddt_app_versions, :os_type, :string, default: 'android'
  end
end
