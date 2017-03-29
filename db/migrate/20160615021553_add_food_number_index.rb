class AddFoodNumberIndex < ActiveRecord::Migration
  def change
    add_index :ddt_orders, :food_number
  end
end
