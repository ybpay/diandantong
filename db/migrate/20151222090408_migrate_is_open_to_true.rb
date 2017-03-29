class MigrateIsOpenToTrue < ActiveRecord::Migration
  def change
    Ddt::Shop.update_all(is_open: true)
  end
end
