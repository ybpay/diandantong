class AddTotalCustomerCountToShift < ActiveRecord::Migration
  def change
    add_column :ddt_shifts, :total_customter_count, :integer
    add_column :ddt_shifts, :total_eat_in_hall_order_count, :integer
    add_column :ddt_shifts, :per_capita_consumption, :decimal, precision: 8, scale: 2
    add_column :ddt_shifts, :per_eat_in_hall_order_consumption, :decimal, precision: 8, scale: 2
  end
end
