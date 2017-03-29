class AddRefundedAmountToOrder < ActiveRecord::Migration
  def change
    add_column :ddt_orders, :refunded_amount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
