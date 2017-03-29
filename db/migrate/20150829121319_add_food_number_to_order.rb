class AddFoodNumberToOrder < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_orders, :food_number
      add_column :ddt_orders, :food_number, :string
    end
  end
end
