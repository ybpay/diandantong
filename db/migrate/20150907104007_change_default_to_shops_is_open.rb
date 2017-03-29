class ChangeDefaultToShopsIsOpen < ActiveRecord::Migration
  def change
  	change_column :ddt_shops, :is_open, :boolean, default: true
  end
end
