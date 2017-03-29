class FixOptionalToComboItem < ActiveRecord::Migration
  def change
  	rename_column :ddt_combo_items, :optional, :is_necessary
  end
end
