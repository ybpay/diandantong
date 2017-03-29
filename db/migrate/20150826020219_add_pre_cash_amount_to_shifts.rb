class AddPreCashAmountToShifts < ActiveRecord::Migration
  def change
    add_column :ddt_shifts, :pre_cash_amount, :decimal, precision: 8, scale: 2
  end
end
