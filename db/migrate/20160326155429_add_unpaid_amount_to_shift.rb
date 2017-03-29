class AddUnpaidAmountToShift < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shifts, :unpaid_amount
      add_column :ddt_shifts, :unpaid_amount, :decimal, precision: 8, scale: 2
    end
  end
end
