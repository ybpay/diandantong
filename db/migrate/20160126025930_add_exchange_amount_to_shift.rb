class AddExchangeAmountToShift < ActiveRecord::Migration
  def change
    add_column :ddt_shifts, :exchange_amount, :decimal, precision: 8, scale: 2
  end
end
