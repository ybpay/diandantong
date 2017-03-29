class AddPaidAmountToPayItem < ActiveRecord::Migration
  def change
    add_column :ddt_pay_items, :paid_amount, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :ddt_pay_items, :change, :decimal, precision: 8, scale: 2,default: 0.0
  end
end
