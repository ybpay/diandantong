class ChangeShiftDefault < ActiveRecord::Migration
  def up
    change_column :ddt_shifts, :recharge_amount, :decimal, precision: 8, scale: 2, default: 0.0
    change_column :ddt_shifts, :pre_cash_amount, :decimal, precision: 8, scale: 2, default: 0.0
    change_column :ddt_shifts, :exchange_amount, :decimal, precision: 8, scale: 2, default: 0.0
  end

  def down
    
  end
end
