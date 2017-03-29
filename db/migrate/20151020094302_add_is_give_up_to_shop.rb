class AddIsGiveUpToShop < ActiveRecord::Migration
  def change
    add_column :ddt_shops, :is_give_up, :boolean, default: false
  end
end
