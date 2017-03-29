class FixAmountForPay < ActiveRecord::Migration
  def change
  	change_column :ddt_orders, :amount_for_pay, :decimal, precision: 8, scale: 2, default: 0.0
  	Ddt::Order.where(:amount_for_pay => nil).update_all(:amount_for_pay => 0.0)
  end
end
