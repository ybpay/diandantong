class AddIsCurrentPrintWhenPlace < ActiveRecord::Migration
  def change
    add_column :ddt_print_settings, :is_current_print_when_place, :boolean, default: false
  end
end
