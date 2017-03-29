class FixIsOpenForShop < ActiveRecord::Migration
  def change
  	change_column :ddt_shops, :is_open, :boolean, default: true
  	Ddt::Shop.where(:is_open => false).update_all(:is_open => true)
  end
end
