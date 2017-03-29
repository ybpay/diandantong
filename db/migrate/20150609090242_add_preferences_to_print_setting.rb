class AddPreferencesToPrintSetting < ActiveRecord::Migration
  def change
    add_column :ddt_print_settings, :preferences, :text
  end
end
