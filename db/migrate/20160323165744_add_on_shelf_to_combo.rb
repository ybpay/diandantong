class AddOnShelfToCombo < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_combos, :on_shelf
      add_column :ddt_combos, :on_shelf, :boolean, default: true
    end
  end
end
